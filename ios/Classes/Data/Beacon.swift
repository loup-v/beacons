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
  let platformCustoms: [String:AnyCodable]
  
  var proximityUUID: String {
    return ids[0].value as! String
  }
  
  var major: Int? {
    if ids.count > 1 {
      return ids[1].value as? Int
    } else {
      return nil
    }
  }
  
  var minor: Int? {
    if ids.count > 2 {
      return ids[2].value as? Int
    } else {
      return nil
    }
  }
  
  init(from beacon: CLBeacon) {
    self.ids = [
      AnyCodable(beacon.proximityUUID.uuidString),
      AnyCodable(beacon.major.intValue),
      AnyCodable(beacon.minor.intValue)
    ]
    
    self.distance = beacon.accuracy
    self.rssi = beacon.rssi
    self.platformCustoms = [
      "proximity": AnyCodable(Proximity(from: beacon.proximity))
    ]
  }
}


