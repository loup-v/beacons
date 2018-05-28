//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.logic

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import io.intheloup.beacons.data.*
import kotlinx.coroutines.experimental.android.UI
import kotlinx.coroutines.experimental.launch
import org.altbeacon.beacon.*
import java.util.*

class BeaconClient(private val permissionClient: PermissionClient) : BeaconConsumer, RangeNotifier, MonitorNotifier {

    private var activity: Activity? = null
    private var beaconManager: BeaconManager? = null
    private var isServiceConnected = false

    private val requests: ArrayList<ActiveRequest> = ArrayList()
    private var isActive = false

    fun bind(activity: Activity) {
        this.activity = activity
        beaconManager = BeaconManager.getInstanceForApplication(activity)

        // Add parsing support for iBeacon and Eddystone
        // https://beaconlayout.wordpress.com/
        beaconManager!!.beaconParsers.add(BeaconParser().setBeaconLayout("m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24"))
        beaconManager!!.beaconParsers.add(BeaconParser().setBeaconLayout("x,s:0-1=feaa,m:2-2=20,d:3-3,d:4-5,d:6-7,d:8-11,d:12-15"))
        beaconManager!!.beaconParsers.add(BeaconParser().setBeaconLayout("s:0-1=feaa,m:2-2=00,p:3-3:-41,i:4-13,i:14-19"))
        beaconManager!!.beaconParsers.add(BeaconParser().setBeaconLayout("s:0-1=feaa,m:2-2=10,p:3-3:-41,i:4-20v"))

        beaconManager!!.bind(this)
    }

    fun unbind() {
        beaconManager!!.removeAllRangeNotifiers()
        beaconManager!!.removeAllMonitorNotifiers()
        beaconManager!!.unbind(this)
        activity = null
        isServiceConnected = false
    }


    // Beacons api

    fun addRequest(request: ActiveRequest, permission: Permission) {
        requests.add(request)

        launch(UI) {
            if (requests.count { request === it } == 0) {
                return@launch
            }

            val result = permissionClient.request(permission)
            if (result !== PermissionClient.PermissionResult.Granted) {
                request.callback(result.result!!)
                return@launch
            }

            startRequest(request)
        }
    }

    fun removeRequest(request: ActiveRequest) {
        val index = requests.indexOfFirst { request === it }
        if (index == -1) return

        stopRequest(request)
        requests.removeAt(index)
    }


    // Lifecycle api

    fun resume() {
        isActive = true
        requests.filter { !it.isRunning }
                .forEach { startRequest(it) }
    }

    fun pause() {
        isActive = false
        requests.filter { it.isRunning && !it.inBackground }
                .forEach { stopRequest(it) }
    }


    // Internals

    private fun startRequest(request: ActiveRequest) {
        if (!isServiceConnected) return

        if (requests.count { it.region.uniqueId == request.region.uniqueId && it.kind == request.kind && it.isRunning } == 0) {
            when (request.kind) {
                ActiveRequest.Kind.Ranging -> beaconManager!!.startRangingBeaconsInRegion(request.region.frameworkValue)
                ActiveRequest.Kind.Monitoring -> beaconManager!!.startMonitoringBeaconsInRegion(request.region.frameworkValue)
            }
        }

        request.isRunning = true
    }

    private fun stopRequest(request: ActiveRequest) {
        request.isRunning = false
        if (!isServiceConnected) return

        if (requests.count { it.region.uniqueId == request.region.uniqueId && it.kind == request.kind && it.isRunning } == 0) {
            when (request.kind) {
                ActiveRequest.Kind.Ranging -> beaconManager!!.stopRangingBeaconsInRegion(request.region.frameworkValue)
                ActiveRequest.Kind.Monitoring -> beaconManager!!.stopMonitoringBeaconsInRegion(request.region.frameworkValue)
            }
        }
    }


    // RangeNotifier

    override fun didRangeBeaconsInRegion(beacons: MutableCollection<Beacon>, region: Region) {
        requests.filter { it.kind == ActiveRequest.Kind.Ranging && it.region.uniqueId == region.uniqueId }
                .forEach { it.callback(Result.success(beacons.map { BeaconModel.parse(it) }, RegionModel.parse(region))) }
    }


    // MonitoringNotifier

    override fun didDetermineStateForRegion(state: Int, region: Region) {

    }

    override fun didEnterRegion(region: Region) {
        requests.filter { it.kind == ActiveRequest.Kind.Monitoring && it.region.uniqueId == region.uniqueId }
                .forEach { it.callback(Result.success(MonitoringEvent.Enter, RegionModel.parse(region))) }
    }

    override fun didExitRegion(region: Region) {
        requests.filter { it.kind == ActiveRequest.Kind.Monitoring && it.region.uniqueId == region.uniqueId }
                .forEach { it.callback(Result.success(MonitoringEvent.Exit, RegionModel.parse(region))) }
    }


    // BeaconsConsumer

    override fun getApplicationContext(): Context {
        return activity!!.applicationContext
    }

    override fun unbindService(p0: ServiceConnection?) {
        return activity!!.unbindService(p0)
    }

    override fun bindService(p0: Intent?, p1: ServiceConnection?, p2: Int): Boolean {
        return activity!!.bindService(p0, p1, p2)
    }

    override fun onBeaconServiceConnect() {
        isServiceConnected = true
        beaconManager!!.addRangeNotifier(this)
        beaconManager!!.addMonitorNotifier(this)

        if (isActive) {
            requests.forEach { startRequest(it) }
        }
    }

    class ActiveRequest(
            val kind: Kind,
            val region: RegionModel,
            val inBackground: Boolean,
            val callback: (Result) -> Unit
    ) {
        var isRunning: Boolean = false

        enum class Kind {
            Ranging, Monitoring
        }
    }
}