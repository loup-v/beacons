//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0

package io.intheloup.beacons.channel

import io.intheloup.beacons.data.RegionModel
import io.intheloup.beacons.data.Permission

class DataRequest(
        val region: RegionModel,
        val permission: Permission,
        val inBackground: Boolean
)