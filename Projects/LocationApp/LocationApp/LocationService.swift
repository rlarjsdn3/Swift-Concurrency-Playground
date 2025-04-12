//
//  LocationService.swift
//  LocationApp
//
//  Created by 김건우 on 4/12/25.
//

import CoreLocation
import Foundation

final class LocationService: NSObject, @unchecked Sendable {

    enum CLError: Error {
        case generic(Error)
        case denied
    }
    
    typealias LocationContinuation = AsyncThrowingStream<CLLocation, Error>.Continuation
    
    private let locationManager = CLLocationManager()
    
    private var continuation: LocationContinuation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupContinuation(_ continuation: LocationContinuation) {
        self.continuation = continuation
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        continuation?.finish()
        continuation = nil
    }
    
    deinit {
        continuation?.finish()
        continuation = nil
    }
}

extension LocationService: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            print("🔵 위치 서비스 접근 허용됨")
        case .notDetermined:
            print("🟡 위치 서비스 접근 결정되지 않음")
            manager.requestWhenInUseAuthorization()
        default: // .denied
            print("🔴 위치 서비스 접근 거부됨")
            continuation?.finish(throwing: CLError.denied)
            continuation = nil
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            continuation?.yield(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: any Error) {
        continuation?.finish(throwing: CLError.generic(error))
        continuation = nil
    }
}
