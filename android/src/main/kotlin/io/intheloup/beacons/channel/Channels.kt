//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.channel

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.intheloup.beacons.BeaconsPlugin
import io.intheloup.beacons.logic.BeaconClient

class Channels : MethodChannel.MethodCallHandler {

    fun register(plugin: BeaconsPlugin) {
        val methodChannel = MethodChannel(plugin.registrar.messenger(), "geolocation/location")
        methodChannel.setMethodCallHandler(this)

        val eventChannel = EventChannel(plugin.registrar.messenger(), "geolocation/locationUpdates")
        eventChannel.setStreamHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result): Unit {
        if (call.method.equals("getPlatformVersion")) {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } else {
            result.notImplemented()
        }
    }

    class Handler(private val beaconClient: BeaconClient,
                  private val kind: BeaconClient.ActiveRequest.Kind) : EventChannel.StreamHandler {

        private var request: BeaconClient.ActiveRequest? = null

        override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
            val dataRequest = Codec.decodeDataRequest(arguments)
            request = BeaconClient.ActiveRequest(kind, dataRequest.region, dataRequest.inBackground) { result->
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