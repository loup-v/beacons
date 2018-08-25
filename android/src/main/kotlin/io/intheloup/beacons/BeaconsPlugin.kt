//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons

import android.app.Activity
import android.app.Application
import android.content.Intent
import android.os.Bundle
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.intheloup.beacons.channel.Channels
import io.intheloup.beacons.data.BackgroundMonitoringEvent
import io.intheloup.beacons.logic.BeaconsClient
import io.intheloup.beacons.logic.PermissionClient

class BeaconsPlugin(val registrar: Registrar) {

    private val permissionClient = PermissionClient()
    private val beaconClient = BeaconsClient(permissionClient)
    private val channels = Channels(permissionClient, beaconClient)

    init {
        registrar.addRequestPermissionsResultListener(permissionClient.listener)

        beaconClient.bind(registrar.activity())
        permissionClient.bind(registrar.activity())

        registrar.activity().application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                beaconClient.bind(activity)
                permissionClient.bind(activity)
            }

            override fun onActivityDestroyed(activity: Activity) {
                // beaconClient.unbind()
                permissionClient.unbind()
            }

            override fun onActivityResumed(activity: Activity?) {
                beaconClient.resume()
            }

            override fun onActivityPaused(activity: Activity?) {
                beaconClient.pause()
            }

            override fun onActivityStarted(activity: Activity?) {

            }

            override fun onActivitySaveInstanceState(activity: Activity?, outState: Bundle?) {

            }

            override fun onActivityStopped(activity: Activity?) {

            }
        })

        channels.register(this)
    }


    companion object {

        fun init(application: Application, callback: BackgroundMonitoringCallback) {
            BeaconsClient.init(application, callback)
        }

        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val plugin = BeaconsPlugin(registrar)
        }
    }

    object Intents {
        const val PermissionRequestId = 92749
    }

    interface BackgroundMonitoringCallback {

        /**
         * Callback on background monitoring events
         *
         * @return true if background mode will end with this event, for instance if an activity has been started.
         * Otherwise return false to continue receiving background events on the current callback
         */
        fun onBackgroundMonitoringEvent(event: BackgroundMonitoringEvent): Boolean
    }
}
