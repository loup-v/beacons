//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

struct Beacon : Codable {
    let ids: [AnyCodable]
    let distance: Double
    let rssi: Int
    let rawData: String
    let platformCustoms: [String:AnyCodable]
    
    init(from beacon: CLBeacon) {
        self.ids = [
            AnyCodable(beacon.proximityUUID.uuidString),
            AnyCodable(beacon.major.intValue),
            AnyCodable(beacon.minor.intValue)
        ]
        
        self.distance = beacon.accuracy
        self.rssi = beacon.rssi
        self.rawData = "UNSUPPORTED"
        self.platformCustoms = [
            "proximity": AnyCodable(Proximity(from: beacon.proximity))
        ]
    }
    
    init(fromRNLBeacon beacon: RNLBeacon) {
        self.ids = [
            AnyCodable(beacon.id1),
            AnyCodable(beacon.id2),
            AnyCodable(beacon.id3)
        ]
        
        self.distance = beacon.beaconDistance.doubleValue
        self.rssi = beacon.rssi as! Int
        self.rawData = beacon.rawData
        self.platformCustoms = [
            "dummy":"dummy"
        ]
    }
}


