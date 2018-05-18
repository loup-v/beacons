//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct Codec {
  private static let jsonEncoder = JSONEncoder()
  private static let jsonDecoder = JSONDecoder()
  
  static func encode<T>(result: Result<T>) -> String {
    return String(data: try! jsonEncoder.encode(result), encoding: .utf8)!
  }
  
  static func decodePermission(from arguments: Any?) -> Permission {
    return Permission(rawValue: arguments! as! String)!
  }
  
  static func decodeRangingRequest(from arugments: Any?) -> RangingRequest {
    return try! jsonDecoder.decode(RangingRequest.self, from: (arugments as! String).data(using: .utf8)!)
  }
}
