//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

struct BeaconRegion : Codable {
  let proximityUUID: String
  let identifier: String
  let major: Int?
  let minor: Int?
  
  init(from region: CLBeaconRegion) {
    self.proximityUUID = region.proximityUUID.uuidString
    self.identifier = region.identifier
    self.major = region.major?.intValue
    self.minor = region.minor?.intValue
  }
  
  var clValue: CLBeaconRegion {
    if let major = major, let minor = minor {
      return CLBeaconRegion(proximityUUID: UUID(uuidString: proximityUUID)!, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: identifier)
    } else if let major = major {
      return CLBeaconRegion(proximityUUID: UUID(uuidString: proximityUUID)!, major: CLBeaconMajorValue(major), identifier: identifier)
    } else {
      return CLBeaconRegion(proximityUUID: UUID(uuidString: proximityUUID)!, identifier: identifier)
    }
  }
}


