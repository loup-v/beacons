//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.data

import org.altbeacon.beacon.Beacon

class BeaconModel(
        val ids: List<String>,
        val distance: Double,
        val rssi: Int
) {
    companion object {
        fun parse(beacon: Beacon) = BeaconModel(
                beacon.identifiers?.map { it.toString() } ?: emptyList(),
                beacon.distance,
                beacon.rssi
        )
    }
}