//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.data

import com.squareup.moshi.FromJson
import com.squareup.moshi.ToJson

class Settings(
        val logs: Logs
) {

    enum class Logs {
        Empty, Verbose, Info, Warning;

        class Adapter {
            @FromJson
            fun fromJson(json: String): Logs =
                    Logs.valueOf(json.capitalize())

            @ToJson
            fun toJson(value: Logs): String =
                    value.toString().decapitalize()
        }
    }
}