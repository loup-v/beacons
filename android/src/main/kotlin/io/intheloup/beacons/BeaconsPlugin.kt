//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons

import android.app.Activity
import android.app.Application
import android.os.Bundle
import io.flutter.plugin.common.PluginRegistry.Registrar
import io.intheloup.beacons.logic.BeaconClient
import io.intheloup.beacons.logic.PermissionClient

class BeaconsPlugin(val registrar: Registrar) {

    private val beaconClient = BeaconClient()
    private val permissionClient = PermissionClient()

    init {
        registrar.addRequestPermissionsResultListener(permissionClient.listener)
        registrar.activity().application.registerActivityLifecycleCallbacks(object : Application.ActivityLifecycleCallbacks {
            override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {
                beaconClient.bind(activity)
                permissionClient.bind(activity)
            }

            override fun onActivityDestroyed(activity: Activity) {
                beaconClient.unbind()
                permissionClient.unbind()
            }

            override fun onActivityPaused(activity: Activity?) {

            }

            override fun onActivityResumed(activity: Activity?) {

            }

            override fun onActivityStarted(activity: Activity?) {

            }

            override fun onActivitySaveInstanceState(activity: Activity?, outState: Bundle?) {

            }

            override fun onActivityStopped(activity: Activity?) {

            }
        })
    }


    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar): Unit {
            val plugin = BeaconsPlugin(registrar)
        }
    }

    object Intents {
        const val PermissionRequestId = 9274
    }
}
