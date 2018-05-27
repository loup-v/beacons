//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.data

import org.altbeacon.beacon.Identifier
import org.altbeacon.beacon.Region

class RegionModel(
        val uniqueId: String,
        val ids: List<String>?,
        val bluetoothAddress: String?
) {
    val frameworkValue: Region
        get() = if (ids != null && bluetoothAddress != null) {
            Region(uniqueId, ids.map { Identifier.parse(it) }, bluetoothAddress)
        } else if (ids != null) {
            Region(uniqueId, ids.map { Identifier.parse(it) })
        } else if (bluetoothAddress != null) {
            Region(uniqueId, bluetoothAddress)
        } else {
            throw IllegalStateException()
        }

    companion object {
        fun parse(region: Region): RegionModel {
            val ids = ArrayList<String>()
            var i = 0
            var id: Identifier? = null
            do {
                id = region.getIdentifier(i)
                id?.let { ids.add(it.toString()) }
                i++
            } while (id != null)

            return RegionModel(region.uniqueId, ids.takeIf { it.isNotEmpty() }, region.bluetoothAddress)
        }
    }
}