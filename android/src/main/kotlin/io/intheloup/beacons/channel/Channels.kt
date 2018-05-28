//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.channel

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.intheloup.beacons.BeaconsPlugin
import io.intheloup.beacons.data.Permission
import io.intheloup.beacons.logic.BeaconClient
import io.intheloup.beacons.logic.PermissionClient
import io.intheloup.streamschannel.StreamsChannel
import kotlinx.coroutines.experimental.android.UI
import kotlinx.coroutines.experimental.launch

class Channels(private val permissionClient: PermissionClient,
               private val beaconClient: BeaconClient) : MethodChannel.MethodCallHandler {

    fun register(plugin: BeaconsPlugin) {
        val methodChannel = MethodChannel(plugin.registrar.messenger(), "beacons")
        methodChannel.setMethodCallHandler(this)

        val rangingChannel = StreamsChannel(plugin.registrar.messenger(), "beacons/ranging")
        rangingChannel.setStreamHandlerFactory { Handler(beaconClient, BeaconClient.ActiveRequest.Kind.Ranging) }

        val monitoringChannel = StreamsChannel(plugin.registrar.messenger(), "beacons/monitoring")
        monitoringChannel.setStreamHandlerFactory { Handler(beaconClient, BeaconClient.ActiveRequest.Kind.Monitoring) }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result): Unit {
        when (call.method) {
            "checkStatus" -> checkStatus(Codec.decodeStatusRequest(call.arguments), result)
            "requestPermission" -> requestPermission(Codec.decodePermission(call.arguments), result)
            else -> result.notImplemented()
        }
    }

    private fun checkStatus(request: StatusRequest, result: MethodChannel.Result) {
        result.success(permissionClient.check(request.permission).result)
    }

    private fun requestPermission(permission: Permission, result: MethodChannel.Result) {
        launch(UI) {
            result.success(permissionClient.check(permission).result)
        }
    }

    class Handler(private val beaconClient: BeaconClient,
                  private val kind: BeaconClient.ActiveRequest.Kind) : EventChannel.StreamHandler {

        private var request: BeaconClient.ActiveRequest? = null

        override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
            val dataRequest = Codec.decodeDataRequest(arguments)
            request = BeaconClient.ActiveRequest(kind, dataRequest.region, dataRequest.inBackground) { result ->
                eventSink.success(Codec.encodeResult(result))
            }
            beaconClient.addRequest(request!!, dataRequest.permission)
        }

        override fun onCancel(arguments: Any?) {
            beaconClient.removeRequest(request!!)
            request = null
        }
    }
}