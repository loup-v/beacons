//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Flutter
import UIKit

public class SwiftBeaconsPlugin: NSObject, FlutterPlugin, UIApplicationDelegate {
  
  internal let registrar: FlutterPluginRegistrar
  private let locationClient = LocationClient()
  private let channel: Channel
  
  init(registrar: FlutterPluginRegistrar) {
    self.registrar = registrar
    self.channel = Channel(locationClient: locationClient)
    super.init()
    
    registrar.addApplicationDelegate(self)
    channel.register(on: self)
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    _ = SwiftBeaconsPlugin(registrar: registrar)
  }
  
  
  // UIApplicationDelegate
  
  public func applicationDidBecomeActive(_ application: UIApplication) {
    locationClient.resume()
  }
  
  public func applicationWillResignActive(_ application: UIApplication) {
    locationClient.pause()
  }
}
