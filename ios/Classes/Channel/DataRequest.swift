//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct DataRequest: Codable {
  let region: BeaconRegion
  let permission: Permission
  let inBackground: Bool
}
