//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct DataRequest: Codable, Equatable {
  let region: BeaconRegion
  let permission: Permission
  let inBackground: Bool
  
  static func ==(lhs: DataRequest, rhs: DataRequest) -> Bool {
    return (lhs.region.identifier == rhs.region.identifier)
  }
}
