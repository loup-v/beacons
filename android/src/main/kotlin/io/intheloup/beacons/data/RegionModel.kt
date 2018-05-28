//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.data

import org.altbeacon.beacon.Identifier
import org.altbeacon.beacon.Region

class RegionModel(
        // Alt-beacon uniqueId
        val identifier: String,
        private val ids: List<Any>?,
        private val bluetoothAddress: String?,
        @Transient private var region: Region?
) {

    val frameworkValue: Region get() = region!!

    fun initFrameworkValue() {
        if (region != null) return

        region = if (ids != null && bluetoothAddress != null) {
            Region(identifier, ids.map { Identifier.parse(it.toString()) }, bluetoothAddress)
        } else if (ids != null) {
            Region(identifier, ids.map { Identifier.parse(it.toString()) })
        } else {
            Region(identifier, bluetoothAddress)
        }
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

            return RegionModel(region.uniqueId, ids.takeIf { it.isNotEmpty() }, region.bluetoothAddress, region)
        }
    }
}