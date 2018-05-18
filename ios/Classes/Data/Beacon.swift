//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

struct Beacon : Codable {
  let proximityUUID: String
  let major: Int
  let minor: Int
  let accuracy: Double
  let proximity: Proximity
  let rssi: Int
  
  init(from beacon: CLBeacon) {
    self.proximityUUID = beacon.proximityUUID.uuidString
    self.major = beacon.major.intValue
    self.minor = beacon.minor.intValue
    self.accuracy = beacon.accuracy
    self.proximity = Proximity(from: beacon.proximity)
    self.rssi = beacon.rssi
  }
}


