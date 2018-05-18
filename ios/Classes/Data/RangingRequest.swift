//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct RangingRequest: Codable {
  let id: Int
  let region: BeaconRegion
  let permission: Permission
  let inBackground: Bool
}
