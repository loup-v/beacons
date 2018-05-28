//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

struct BeaconRegion : Codable {
  let identifier: String
  let ids: [AnyCodable]
  
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
  
  
  init(from region: CLBeaconRegion) {
    self.identifier = region.identifier
    var ids = [
      AnyCodable(region.proximityUUID.uuidString)
    ]
    
    if let major = region.major?.intValue {
      ids.append(AnyCodable(major))
      
      if let minor = region.minor?.intValue {
        ids.append(AnyCodable(minor))
      }
    }
    
    self.ids = ids
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


