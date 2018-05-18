//
//  Copyright (c) 2018 Loup Inc.
//  Licensed under Apache License v2.0
//

import Foundation
import CoreLocation

class LocationClient : NSObject, CLLocationManagerDelegate {
  
  private let locationManager = CLLocationManager()
  private var permissionCallbacks: Array<Callback<Void, Void>> = []
  
  private var rangingCallback: RangingCallback? = nil
  private var rangingRequests: Array<RangingRequest> = []
  
  private var hasLocationRequest: Bool {
    return !rangingRequests.isEmpty
  }
  private var hasInBackgroundLocationRequest: Bool {
    return !rangingRequests.filter { $0.inBackground == true }.isEmpty
  }
  
  private var isPaused = false
  
  override init() {
    super.init()
    locationManager.delegate = self
  }
  
  
  // One shot API
  
  func isRangingOperational(with permission: Permission) -> Result<Bool> {
    let status: ServiceStatus<Bool> = currentServiceStatus(with: permission, region: nil)
    return status.isReady ? Result<Bool>.success(with: true) : status.failure!
  }
  
  func requestLocationPermission(with permission: Permission, _ callback: @escaping (Result<Bool>) -> Void) {
    runWithValidServiceStatus(with: permission, region: nil, success: {
      callback(Result<Bool>.success(with: true))
    }, failure: { result in
      callback(result)
    })
  }
  
  
  // Updates API
  
  func startRanging(request: RangingRequest) {
    runWithValidServiceStatus(with: request.permission, region: request.region, success: {
      self.rangingRequests.append(request)
      self.locationManager.startRangingBeacons(in: request.region.clValue)
    }, failure: { result in
      self.rangingCallback!(result)
    })
  }
  
  func stopRanging(request: RangingRequest) {
    guard let index = rangingRequests.index(where: { $0.id == request.id }) else {
      return
    }
    
    rangingRequests.remove(at: index)
    locationManager.stopRangingBeacons(in: request.region.clValue)
  }
  
  func registerRangingUpdates(callback: @escaping RangingCallback) {
    precondition(rangingCallback == nil, "trying to register a 2nd location updates callback")
    rangingCallback = callback
  }
  
  func deregisterRangingUpdatesCallback() {
    precondition(rangingCallback != nil, "trying to deregister a non-existent location updates callback")
    rangingCallback = nil
  }
  
  
  // Lifecycle API
  
  func resume() {
    guard hasLocationRequest && isPaused else {
      return
    }
    
    isPaused = false
    rangingRequests.forEach {
      locationManager.startRangingBeacons(in: $0.region.clValue)
    }
  }
  
  func pause() {
    guard hasLocationRequest && !isPaused && !hasInBackgroundLocationRequest else {
      return
    }
    
    isPaused = true
    rangingRequests.forEach {
      locationManager.stopRangingBeacons(in: $0.region.clValue)
    }
  }
  
  
  // Service status
  
  private func runWithValidServiceStatus<T>(with permission: Permission, region: BeaconRegion?, success: @escaping () -> Void, failure: @escaping (Result<T>) -> Void) {
    let status: ServiceStatus<T> = currentServiceStatus(with: permission, region: region)
    
    if status.isReady {
      success()
    } else {
      if let permission = status.needsAuthorization {
        let callback = Callback<Void, Void>(
          success: { _ in success() },
          failure: { _ in failure(Result<T>.failure(of: .permissionDenied, for: region)) }
        )
        permissionCallbacks.append(callback)
        locationManager.requestAuthorization(for: permission)
      } else {
        failure(status.failure!)
      }
    }
  }
  
  private func currentServiceStatus<T>(with permission: Permission, region: BeaconRegion?) -> ServiceStatus<T> {
    guard CLLocationManager.locationServicesEnabled() else {
      return ServiceStatus<T>(isReady: false, needsAuthorization: nil, failure: Result<T>.failure(of: .serviceDisabled, for: region))
    }
    
    guard CLLocationManager.isRangingAvailable() else {
      return ServiceStatus<T>(isReady: false, needsAuthorization: nil, failure: Result<T>.failure(of: .rangingUnavailable, for: region))
    }
    
    switch CLLocationManager.authorizationStatus() {
    case .notDetermined:
      guard locationManager.isPermissionDeclared(for: permission) else {
        return ServiceStatus<T>(isReady: false, needsAuthorization: nil, failure: Result<T>.failure(of: .runtime, message: "Missing location usage description values in Info.plist. See readme for details.", fatal: true, for: region))
      }
      
      return ServiceStatus<T>(isReady: false, needsAuthorization: permission, failure: Result<T>.failure(of: .permissionDenied, for: region))
    case .denied:
      return ServiceStatus<T>(isReady: false, needsAuthorization: nil, failure: Result<T>.failure(of: .permissionDenied, for: region))
    case .restricted:
      return ServiceStatus<T>(isReady: false, needsAuthorization: nil, failure: Result<T>.failure(of: .serviceDisabled, for: region))
    case .authorizedWhenInUse, .authorizedAlways:
      return ServiceStatus<T>(isReady: true, needsAuthorization: nil, failure: nil)
    }
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
    if !beacons.isEmpty {
      rangingCallback?(Result<[Beacon]>.success(with: beacons.map { Beacon(from: $0) }, for: BeaconRegion(from: region)))
    } else {
      rangingCallback?(Result<[Beacon]>.failure(of: .notFound, for: BeaconRegion(from: region)))
    }
  }
  
  func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
    rangingCallback!(Result<[Beacon]>.failure(of: .runtime, message: error.localizedDescription, for: BeaconRegion(from: region)))
  }
  
  struct Callback<T, E> {
    let success: (T) -> Void
    let failure: (E) -> Void
  }
  
  typealias RangingCallback = (Result<[Beacon]>) -> Void
  
  struct ServiceStatus<T: Codable> {
    let isReady: Bool
    let needsAuthorization: Permission?
    let failure: Result<T>?
  }
}
