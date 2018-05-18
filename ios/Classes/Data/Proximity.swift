//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

enum Proximity: String, Codable {
  case unknown = "unknown"
  case immediate = "immediate"
  case near = "near"
  case far = "far"
  
  init(from clValue: CLProximity) {
    switch clValue {
    case .unknown:
      self = .unknown
    case .immediate:
      self = .immediate
    case .near:
      self = .near
    case .far:
      self = .far
    }
  }
  
  var clValue: CLProximity {
    switch self {
    case .unknown:
      return CLProximity.unknown
    case .immediate:
      return CLProximity.immediate
    case .near:
      return CLProximity.near
    case .far:
      return CLProximity.far
    }
  }
  
  
}
