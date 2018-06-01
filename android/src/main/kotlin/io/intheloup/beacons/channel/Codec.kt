//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.channel

import com.squareup.moshi.Moshi
import io.intheloup.beacons.data.MonitoringState
import io.intheloup.beacons.data.Permission
import io.intheloup.beacons.data.Result
import io.intheloup.beacons.data.Settings

object Codec {

    private val moshi: Moshi = Moshi.Builder()
            .add(Permission.Adapter())
            .add(MonitoringState.Adapter())
            .add(Settings.Logs.Adapter())
            .build()

    fun encodeResult(result: Result): String =
            moshi.adapter(Result::class.java).toJson(result)

    fun decodePermission(arguments: Any?): Permission =
            Permission.Adapter().fromJson(arguments!! as String)

    fun decodeDataRequest(arguments: Any?): DataRequest =
            moshi.adapter(DataRequest::class.java).fromJson(arguments!! as String)!!

    fun decodeStatusRequest(arguments: Any?): StatusRequest =
            moshi.adapter(StatusRequest::class.java).fromJson(arguments!! as String)!!

    fun decodeSettings(arguments: Any?): Settings =
            moshi.adapter(Settings::class.java).fromJson(arguments!! as String)!!

}
