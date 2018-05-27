//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.data

data class Result(val isSuccessful: Boolean,
                  val region: RegionModel? = null,
                  val data: Any? = null,
                  val error: Error? = null
) {
    companion object {
        fun success(data: Any, region: RegionModel? = null) = Result(isSuccessful = true, data = data)

        fun failure(type: String, region: RegionModel? = null, message: String? = null, fatal: Boolean = false) = Result(
                isSuccessful = false,
                error = Result.Error(
                        type = type,
                        message = message,
                        fatal = fatal
                )
        )
    }

    data class Error(val type: String,
                     val message: String?,
                     val fatal: Boolean) {

        object Type {
            const val Runtime = "runtime"
            const val LocationNotFound = "locationNotFound"
            const val PermissionDenied = "permissionDenied"
            const val ServiceDisabled = "serviceDisabled"
        }
    }
}