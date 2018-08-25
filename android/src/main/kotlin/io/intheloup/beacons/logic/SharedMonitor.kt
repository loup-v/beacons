//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.logic

import android.app.Application
import android.content.Context
import android.util.Log
import io.intheloup.beacons.BeaconsPlugin
import io.intheloup.beacons.data.BackgroundMonitoringEvent
import io.intheloup.beacons.data.MonitoringState
import io.intheloup.beacons.data.RegionModel
import org.altbeacon.beacon.Identifier
import org.altbeacon.beacon.MonitorNotifier
import org.altbeacon.beacon.Region
import org.altbeacon.beacon.startup.BootstrapNotifier
import org.altbeacon.beacon.startup.RegionBootstrap
import java.util.*


class SharedMonitor(private val application: Application,
                    private val callback: BeaconsPlugin.BackgroundMonitoringCallback) : MonitorNotifier, BootstrapNotifier {

    private val backgroundEvents = ArrayList<BackgroundMonitoringEvent>()
    private val backgroundListeners = ArrayList<BackgroundListener>()
    private val regionBootstrap = RegionBootstrap(this, ArrayList())
    private var isBackgroundCallbackProcessed = false

    private var foregroundNotifier: MonitorNotifier? = null

    init {
        // When monitor is running in background, it might not detect right monitoring event
        // probably happen only on android 8+ with the 15min scan delay
        // however by add/removing a random region, it triggers a monitoring scan directly
        // making background monitoring detection much faster
        // todo: discuss this with android-beacon-library's author
        val fakeRegion = Region(UUID.randomUUID().toString(), Identifier.fromUuid(UUID.randomUUID()), null, null)
        regionBootstrap.addRegion(fakeRegion)
        regionBootstrap.removeRegion(fakeRegion)
    }

    fun attachForegroundNotifier(notifier: MonitorNotifier) {
        Log.d(Tag, "attach foreground notifier")
        this.foregroundNotifier = null

        // foreground notifier being attached means background logic is already processed
        // or not needed anymore
        isBackgroundCallbackProcessed = true
    }

    fun detachForegroundNotifier(notifier: MonitorNotifier) {
        Log.d(Tag, "detach foreground notifier")
        // check(this.foregroundNotifier == notifier)
        this.foregroundNotifier = null
    }

    fun start(region: RegionModel) {
        regionBootstrap.addRegion(region.frameworkValue)
    }

    fun stop(region: RegionModel) {
        regionBootstrap.removeRegion(region.frameworkValue)
    }

    fun addBackgroundListener(listener: BackgroundListener) {
        backgroundListeners.add(listener)

        if (backgroundEvents.isNotEmpty()) {
            backgroundEvents.forEach { listener.callback(it) }
            backgroundEvents.clear()
        }
    }

    fun removeBackgroundListener(listener: BackgroundListener) {
        backgroundListeners.remove(listener)
    }

    private fun notifyBackground(event: BackgroundMonitoringEvent) {
        Log.d(Tag, "notify background: ${event.type} / ${event.state}")

        if (!isBackgroundCallbackProcessed) {
            isBackgroundCallbackProcessed = callback.onBackgroundMonitoringEvent(event)
        }

        if (backgroundListeners.isNotEmpty()) {
            backgroundListeners.forEach { it.callback(event) }
        } else {
            backgroundEvents.add(event)
        }
    }

    override fun getApplicationContext(): Context {
        return application
    }

    override fun didDetermineStateForRegion(state: Int, region: Region) {
        Log.d(Tag, "didDetermineStateForRegion: ${region.uniqueId} [$state]")
    }

    override fun didEnterRegion(region: Region) {
        Log.d(Tag, "didEnterRegion: ${region.uniqueId}")

        if (foregroundNotifier != null) {
            foregroundNotifier!!.didEnterRegion(region)
        } else {
            notifyBackground(BackgroundMonitoringEvent("didEnterRegion", RegionModel.parse(region), MonitoringState.EnterOrInside))
        }
    }

    override fun didExitRegion(region: Region) {
        Log.d(Tag, "didExitRegion: ${region.uniqueId}")

        if (foregroundNotifier != null) {
            foregroundNotifier!!.didExitRegion(region)
        } else {
            notifyBackground(BackgroundMonitoringEvent("didExitRegion", RegionModel.parse(region), MonitoringState.ExitOrOutside))
        }
    }

    class BackgroundListener(val callback: (BackgroundMonitoringEvent) -> Unit)

    companion object {
        private const val Tag = "beacons monitoring"
    }
}