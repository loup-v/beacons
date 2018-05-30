//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

class LocationClient : NSObject, CLLocationManagerDelegate {
  
  private let locationManager = CLLocationManager()
  private var permissionCallbacks: Array<Callback<Void, Void>> = []
  private var requests: Array<ActiveRequest> = [];
  private var backgroundMonitoringListeners = [BackgroundMonitoringListener]()
  private var backgroundMonitoringEvents = [BackgroundMonitoringEvent]()
  
  override init() {
    super.init()
    locationManager.delegate = self
    locationManager.pausesLocationUpdatesAutomatically = false
    if #available(iOS 9.0, *) {
      locationManager.allowsBackgroundLocationUpdates = true
    }
  }
  
  
  // Status
  
  func checkStatus(for request: StatusRequest) -> Result {
    let status: ServiceStatus = getStatus(for: request, region: nil)
    return status.isReady ? Result.success(with: true) : status.failure!
  }
  
  func request(permission: Permission, _ callback: @escaping (Result) -> Void) {
    runWithValidStatus(for: StatusRequest(ranging: false, monitoring: false, permission: permission), region: nil, success: {
      callback(Result.success(with: true))
    }, failure: { result in
      callback(result)
    })
  }
  
  
  // Request API
  
  func add(request: ActiveRequest, with permission: Permission) {
    guard request.frameworkRegion != nil else {
      return
    }
    
    requests.append(request)
    
    runWithValidStatus(for: StatusRequest(ranging: true, monitoring: false, permission: permission), region: request.region, success: {
      guard self.requests.contains(where: { $0 === request }) else {
        return
      }
      self.start(request: request)
    }, failure: { result in
      guard self.requests.contains(where: { $0 === request }) else {
        return
      }
      request.callback(result)
    })
  }
  
  func remove(request: ActiveRequest) {
    guard let index = requests.index(where:  { $0 === request }) else {
      return
    }
    
    stop(request: request)
    requests.remove(at: index)
  }
  
  func add(backgroundMonitoringListener listener: BackgroundMonitoringListener) {
    backgroundMonitoringListeners.append(listener)
    
    if UIApplication.shared.applicationState == .background && !backgroundMonitoringEvents.isEmpty {
      backgroundMonitoringEvents.forEach { listener.callback($0) }
      backgroundMonitoringEvents.removeAll()
    }
  }
  
  func remove(backgroundMonitoringListener listener: BackgroundMonitoringListener) {
    if let index = backgroundMonitoringListeners.index(where: { $0 === listener }) {
      backgroundMonitoringListeners.remove(at: index)
    }
  }
  
  
  // Lifecycle API
  
  func resume() {
    backgroundMonitoringEvents.removeAll()
    
    requests
      .filter { !$0.isRunning }
      .forEach { start(request: $0) }
  }
  
  func pause() {
    requests
      .filter { $0.isRunning && !$0.inBackground }
      .forEach { stop(request: $0) }
  }
  
  
  // Request internals
  
  private func start(request: ActiveRequest) {
    if !requests.contains(where: { $0.region.identifier == request.region.identifier && $0.kind == request.kind && $0.isRunning }) {
      switch request.kind {
      case .ranging:
        locationManager.startRangingBeacons(in: request.frameworkRegion!)
      case .monitoring:
        locationManager.startMonitoring(for: request.frameworkRegion!)
      }
    }
    
    request.isRunning = true
  }
  
  private func stop(request: ActiveRequest) {
    request.isRunning = false
    
    if !requests.contains(where: { $0.region.identifier == request.region.identifier && $0.kind == request.kind && $0.isRunning }) {
      switch request.kind {
      case .ranging:
        locationManager.stopRangingBeacons(in: request.frameworkRegion!)
      case .monitoring:
        locationManager.stopMonitoring(for: request.frameworkRegion!)
      }
    }
  }
  
  private func notify(for event: BackgroundMonitoringEvent) {
    guard UIApplication.shared.applicationState == .background else {
      return
    }
    
    if !backgroundMonitoringListeners.isEmpty {
      backgroundMonitoringListeners.forEach {
        $0.callback(event)
      }
    } else {
      backgroundMonitoringEvents.append(event)
    }
  }
  
  
  // Status
  
  private func runWithValidStatus(for request: StatusRequest, region: BeaconRegion?, success: @escaping () -> Void, failure: @escaping (Result) -> Void) {
    let status: ServiceStatus = getStatus(for: request, region: region)
    
    if status.isReady {
      success()
    } else {
      if let permission = status.needsAuthorization {
        let callback = Callback<Void, Void>(
          success: { _ in success() },
          failure: { _ in failure(Result.failure(of: .permissionDenied, for: region)) }
        )
        permissionCallbacks.append(callback)
        locationManager.requestAuthorization(for: permission)
      } else {
        failure(status.failure!)
      }
    }
  }
  
  private func getStatus(for request: StatusRequest, region: BeaconRegion?) -> ServiceStatus {
    if request.ranging || request.monitoring {
      guard CLLocationManager.locationServicesEnabled() else {
        return ServiceStatus(isReady: false, needsAuthorization: nil, failure: Result.failure(of: .serviceDisabled, for: region))
      }
      
      if request.ranging && !CLLocationManager.isRangingAvailable() {
        return ServiceStatus(isReady: false, needsAuthorization: nil, failure: Result.failure(of: .rangingUnavailable, for: region))
      }
      
      if request.monitoring && !CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        return ServiceStatus(isReady: false, needsAuthorization: nil, failure: Result.failure(of: .monitoringUnavailable, for: region))
      }
    }
    
    if let permission = request.permission {
      switch CLLocationManager.authorizationStatus() {
      case .notDetermined:
        guard locationManager.isPermissionDeclared(for: permission) else {
          return ServiceStatus(isReady: false, needsAuthorization: nil, failure: Result.failure(of: .runtime, message: "Missing location usage description values in Info.plist. See readme for details.", fatal: true, for: region))
        }
        
        return ServiceStatus(isReady: false, needsAuthorization: permission, failure: Result.failure(of: .permissionDenied, for: region))
      case .denied:
        return ServiceStatus(isReady: false, needsAuthorization: nil, failure: Result.failure(of: .permissionDenied, for: region))
      case .restricted:
        return ServiceStatus(isReady: false, needsAuthorization: nil, failure: Result.failure(of: .serviceDisabled, for: region))
      case .authorizedWhenInUse, .authorizedAlways:
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse && permission == .always {
          return ServiceStatus(isReady: false, needsAuthorization: permission, failure: Result.failure(of: .permissionDenied, for: region))
        } else {
          return ServiceStatus(isReady: true, needsAuthorization: nil, failure: nil)
        }
      }
    }
    
    return ServiceStatus(isReady: true, needsAuthorization: nil, failure: nil)
  }
  
  
  // CLLocationManagerDelegate
  
  public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    permissionCallbacks.forEach { action in
      if status == .authorizedAlways || status == .authorizedWhenInUse {
        action.success(())
      } else {
        action.failure(())
      }
    }
    permissionCallbacks.removeAll()
  }
  
  func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
    requests
      .filter { $0.kind == .ranging && $0.region.identifier == region.identifier }
      .forEach {
        $0.callback(Result.success(with: beacons.map { Beacon(from: $0) }, for: BeaconRegion(from: region)))
      }
  }
  
  func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
    requests
      .filter { $0.kind == .ranging && $0.region.identifier == region.identifier }
      .forEach {
        $0.callback(Result.failure(of: .runtime, message: error.localizedDescription, for: BeaconRegion(from: region)))
      }
  }
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    guard region is CLBeaconRegion else { return }
    print("didEnterRegion: \(region.identifier)")
    
    requests
      .filter { $0.kind == .monitoring && $0.region.identifier == region.identifier }
      .forEach {
        $0.callback(Result.success(with: MonitoringState.enterOrInside, for: BeaconRegion(from: region as! CLBeaconRegion)))
      }
    
    notify(for: BackgroundMonitoringEvent(type: "didEnterRegion", region: BeaconRegion(from: region as! CLBeaconRegion), state: MonitoringState.enterOrInside))
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    print("didExitRegion: \(region.identifier)")
    guard region is CLBeaconRegion else { return }
    
    requests
      .filter { $0.kind == .monitoring && $0.region.identifier == region.identifier }
      .forEach {
        $0.callback(Result.success(with: MonitoringState.exitOrOutside, for: BeaconRegion(from: region as! CLBeaconRegion)))
      }
    
    notify(for: BackgroundMonitoringEvent(type: "didExitRegion", region: BeaconRegion(from: region as! CLBeaconRegion), state: MonitoringState.exitOrOutside))
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    guard region != nil && region is CLBeaconRegion else { return }
    
    requests
      .filter { $0.kind == .monitoring && $0.region.identifier == region!.identifier }
      .forEach {
        $0.callback(Result.failure(of: .runtime, message: error.localizedDescription, for: BeaconRegion(from: region as! CLBeaconRegion)))
      }
  }
  
  func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
    guard region is CLBeaconRegion else { return }
    let monitoringState = MonitoringState(from: state)
    print("didDetermineState: \(monitoringState) forRegion: \(region.identifier)")
    
    notify(for: BackgroundMonitoringEvent(type: "didDetermineState", region: BeaconRegion(from: region as! CLBeaconRegion), state: monitoringState))
  }
  
  func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
    print("didStartMonitoringForRegion: \(region.identifier)")
  }
  
  struct Callback<T, E> {
    let success: (T) -> Void
    let failure: (E) -> Void
  }
  
  struct ServiceStatus {
    let isReady: Bool
    let needsAuthorization: Permission?
    let failure: Result?
  }
  
  class BackgroundMonitoringListener {
    let callback: (BackgroundMonitoringEvent) -> Void
    init(callback: @escaping (BackgroundMonitoringEvent) -> Void) {
      self.callback = callback
    }
  }
  
  class ActiveRequest {
    let kind: Kind
    let region: BeaconRegion
    let inBackground: Bool
    var frameworkRegion: CLBeaconRegion?
    var callback: (Result) -> Void;
    var isRunning: Bool = false
    
    init(kind: Kind, region: BeaconRegion, inBackground: Bool, callback: @escaping (Result) -> Void) {
      self.kind = kind
      self.region = region
      self.inBackground = inBackground
      self.callback = callback
      
      initFrameworkRegion()
    }
    
    private func initFrameworkRegion() {
      let uuid = UUID(uuidString: region.proximityUUID)
      guard uuid != nil else {
        callback(Result.failure(of: .runtime, message: "Invalid proximityUUID: \(region.proximityUUID)", fatal: false, for: region))
        return
      }
      
      if let major = region.major, let minor = region.minor {
        frameworkRegion = CLBeaconRegion(proximityUUID: uuid!, major: CLBeaconMajorValue(major), minor: CLBeaconMinorValue(minor), identifier: region.identifier)
      } else if let major = region.major {
        frameworkRegion = CLBeaconRegion(proximityUUID: uuid!, major: CLBeaconMajorValue(major), identifier: region.identifier)
      } else {
        frameworkRegion = CLBeaconRegion(proximityUUID: uuid!, identifier: region.identifier)
      }
      
      frameworkRegion!.notifyEntryStateOnDisplay = inBackground
    }
    
    enum Kind {
      case ranging, monitoring
    }
  }
}
