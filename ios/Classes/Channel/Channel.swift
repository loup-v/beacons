//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

class Channel {
  
  private let locationClient: LocationClient
  private let rangingHandler: RangingHandler
  private let monitoringHandler: MonitoringHandler
  
  init(locationClient: LocationClient) {
    self.locationClient = locationClient
    self.rangingHandler = RangingHandler(locationClient: locationClient)
    self.monitoringHandler = MonitoringHandler(locationClient: locationClient)
  }
  
  func register(on plugin: SwiftBeaconsPlugin) {
    let methodChannel = FlutterMethodChannel(name: "beacons", binaryMessenger: plugin.registrar.messenger())
    methodChannel.setMethodCallHandler(handleMethodCall(_:result:))
    
    let rangingChannel = FlutterEventChannel(name: "beacons/ranging", binaryMessenger: plugin.registrar.messenger())
    rangingChannel.setStreamHandler(rangingHandler)
    
    let monitoringChannel = FlutterEventChannel(name: "beacons/monitoring", binaryMessenger: plugin.registrar.messenger())
    monitoringChannel.setStreamHandler(monitoringHandler)
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "checkStatus":
      checkStatus(for: Codec.decodeStatusRequest(from: call.arguments), on: result)
    case "requestPermission":
      request(permission: Codec.decodePermission(from: call.arguments), on: result)
    case "startRanging":
      startRanging(for: Codec.decodeDataRequest(from: call.arguments))
    case "stopRanging":
      stopRanging(for: call.arguments as! String)
    case "startMonitoring":
      startMonitoring(for: Codec.decodeDataRequest(from: call.arguments))
    case "stopMonitoring":
      stopMonitoring(for: call.arguments as! String)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func checkStatus(for request: StatusRequest, on flutterResult: @escaping FlutterResult) {
    flutterResult(Codec.encode(result: locationClient.checkStatus(for: request)))
  }
  
  private func request(permission: Permission, on flutterResult: @escaping FlutterResult) {
    locationClient.request(permission: permission) { result in
      flutterResult(Codec.encode(result: result))
    }
  }
  
  private func startRanging(for request: DataRequest) {
    locationClient.startRanging(for: request)
  }
  
  private func stopRanging(for identifier: String) {
    locationClient.stopRanging(for: identifier)
  }
  
  private func startMonitoring(for request: DataRequest) {
    locationClient.startMonitoring(for: request)
  }
  
  private func stopMonitoring(for identifier: String) {
    locationClient.stopMonitoring(for: identifier)
  }
  
  
  class RangingHandler: NSObject, FlutterStreamHandler {
    private let locationClient: LocationClient
    
    init(locationClient: LocationClient) {
      self.locationClient = locationClient
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      locationClient.registerRangingCallback { result in
        events(Codec.encode(result: result))
      }
      return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      locationClient.deregisterRangingCallback()
      return nil
    }
  }
  
  class MonitoringHandler: NSObject, FlutterStreamHandler {
    private let locationClient: LocationClient
    
    init(locationClient: LocationClient) {
      self.locationClient = locationClient
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      locationClient.registerMonitoringCallback { result in
        events(Codec.encode(result: result))
      }
      return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      locationClient.deregisterMonitoringCallback()
      return nil
    }
  }
}
