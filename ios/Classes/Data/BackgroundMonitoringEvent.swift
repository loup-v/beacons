//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct BackgroundMonitoringEvent : Codable {
  let name: String
  let region: BeaconRegion
  let state: MonitoringState
}
