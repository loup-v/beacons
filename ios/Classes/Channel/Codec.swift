//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation

struct Codec {
  private static let jsonEncoder = JSONEncoder()
  private static let jsonDecoder = JSONDecoder()
  
  static func encode(result: Result) -> String {
    return String(data: try! jsonEncoder.encode(result), encoding: .utf8)!
  }
  
  static func encode(backgroundMonitoringEvent event: BackgroundMonitoringEvent) -> String {
    return String(data: try! jsonEncoder.encode(event), encoding: .utf8)!
  }
  
  static func decodePermission(from arguments: Any?) -> Permission {
    return Permission(rawValue: arguments! as! String)!
  }
  
  static func decodeStatusRequest(from arugments: Any?) -> StatusRequest {
    return try! jsonDecoder.decode(StatusRequest.self, from: (arugments as! String).data(using: .utf8)!)
  }
  
  static func decodeDataRequest(from arugments: Any?) -> DataRequest {
    return try! jsonDecoder.decode(DataRequest.self, from: (arugments as! String).data(using: .utf8)!)
  }
}
