//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

class BeaconsChannel {
  
  private let locationClient: LocationClient
  private let updatesHandler: UpdatesHandler
  
  init(locationClient: LocationClient) {
    self.locationClient = locationClient
    self.updatesHandler = UpdatesHandler(locationClient: locationClient)
  }
  
  func register(on plugin: SwiftBeaconsPlugin) {
    let methodChannel = FlutterMethodChannel(name: "beacons", binaryMessenger: plugin.registrar.messenger())
    methodChannel.setMethodCallHandler(handleMethodCall(_:result:))
    
    let eventChannel = FlutterEventChannel(name: "beacons/rangingUpdates", binaryMessenger: plugin.registrar.messenger())
    eventChannel.setStreamHandler(updatesHandler)
  }
  
  private func handleMethodCall(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isRangingOperational":
      isRangingOperational(permission: Codec.decodePermission(from: call.arguments), on: result)
    case "requestLocationPermission":
      requestLocation(permission: Codec.decodePermission(from: call.arguments), on: result)
    case "startRangingRequest":
      startRanging(request: Codec.decodeRangingRequest(from: call.arguments))
    case "stopRangingRequest":
      stopRanging(request: Codec.decodeRangingRequest(from: call.arguments))
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  private func isRangingOperational(permission: Permission, on flutterResult: @escaping FlutterResult) {
    flutterResult(Codec.encode(result: locationClient.isRangingOperational(with: permission)))
  }
  
  private func requestLocation(permission: Permission, on flutterResult: @escaping FlutterResult) {
    locationClient.requestLocationPermission(with: permission) { result in
      flutterResult(Codec.encode(result: result))
    }
  }
  
  private func startRanging(request: RangingRequest) {
    locationClient.startRanging(request: request)
  }
  
  private func stopRanging(request: RangingRequest) {
    locationClient.stopRanging(request: request)
  }
  
  
  class UpdatesHandler: NSObject, FlutterStreamHandler {
    private let locationClient: LocationClient
    
    init(locationClient: LocationClient) {
      self.locationClient = locationClient
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
      locationClient.registerRangingUpdates { result in
        events(Codec.encode(result: result))
      }
      return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
      locationClient.deregisterRangingUpdatesCallback()
      return nil
    }
  }
}
