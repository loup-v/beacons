//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct Result : Codable {
  let isSuccessful: Bool
  let region: BeaconRegion?
  let data: AnyCodable?
  let error: ResultError?
  
  static func success <T: Codable> (with data: T, for region: BeaconRegion? = nil) -> Result {
    return Result(isSuccessful: true, region: region, data: AnyCodable(data), error: nil)
  }
  
  static func failure (of type: ResultError.Kind, message: String? = nil, fatal: Bool? = nil, for region: BeaconRegion? = nil) -> Result {
    return Result(isSuccessful: false, region: region, data: nil, error: ResultError(type: type, message: message, fatal: fatal))
  }
}

struct ResultError: Codable {
  let type: Kind
  let message: String?
  let fatal: Bool?
  
  enum Kind: String, Codable {
    case runtime = "runtime"
    case permissionDenied = "permissionDenied"
    case serviceDisabled = "serviceDisabled"
    case rangingUnavailable = "rangingUnavailable"
    case monitoringUnavailable = "monitoringUnavailable"
  }
}


