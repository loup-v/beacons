//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.logic

import android.app.Activity
import android.content.pm.PackageManager
import android.support.v4.app.ActivityCompat
import io.flutter.plugin.common.PluginRegistry
import io.intheloup.beacons.BeaconsPlugin
import io.intheloup.beacons.data.Permission
import java.util.*
import kotlin.coroutines.experimental.suspendCoroutine

class PermissionClient {

    val listener: PluginRegistry.RequestPermissionsResultListener = PluginRegistry.RequestPermissionsResultListener { id, _, grantResults ->
        if (id == BeaconsPlugin.Intents.PermissionRequestId) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                permissionCallbacks.forEach { it.success(Unit) }
            } else {
                permissionCallbacks.forEach { it.failure(Unit) }
            }
            permissionCallbacks.clear()
            return@RequestPermissionsResultListener true
        }

        return@RequestPermissionsResultListener false
    }

    private var activity: Activity? = null
    private val permissionCallbacks = ArrayList<Callback<Unit, Unit>>()


    fun bind(activity: Activity) {
        this.activity = activity
    }

    fun unbind() {
        activity = null
    }


    // Internals

    // Permission

    private suspend fun requestPermission(permission: Permission): Boolean = suspendCoroutine { cont ->
        val callback = Callback<Unit, Unit>(
                success = { _ -> cont.resume(true) },
                failure = { _ -> cont.resume(false) }
        )
        permissionCallbacks.add(callback)
        ActivityCompat.requestPermissions(activity!!, arrayOf(permission.manifestValue), BeaconsPlugin.Intents.PermissionRequestId)
    }


    class Callback<in T, in E>(val success: (T) -> Unit, val failure: (E) -> Unit)
}