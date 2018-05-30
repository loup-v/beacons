//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

enum MonitoringState: String, Codable {
  case enterOrInside = "enterOrInside"
  case exitOrOutside = "exitOrOutside"
  case unknown = "unknown"
  
  init(from regionState: CLRegionState) {
    switch regionState {
    case .inside:
      self = MonitoringState.enterOrInside
    case .outside:
      self = MonitoringState.exitOrOutside
    case .unknown:
      self = MonitoringState.unknown
    }
  }
}
