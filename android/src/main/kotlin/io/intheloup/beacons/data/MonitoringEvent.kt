//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.data

import com.squareup.moshi.FromJson
import com.squareup.moshi.ToJson

enum class MonitoringEvent {
    Enter, Exit;

    class Adapter {
        @FromJson
        fun fromJson(json: String): MonitoringEvent =
                MonitoringEvent.valueOf(json.capitalize())

        @ToJson
        fun toJson(value: MonitoringEvent): String =
                value.toString().toLowerCase()
    }
}