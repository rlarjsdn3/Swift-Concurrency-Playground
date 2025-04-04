//
//  LocationService.swift
//  Map
//
//  Created by 김건우 on 3/27/25.
//

import CoreLocation
import Foundation

protocol LocationService {
    typealias CLContinuation = CheckedContinuation<CLLocation, Error>
    
    func start()
    func stop()
    func setupContinuation(_ continuation: CLContinuation)
}

enum LocationError: Error {
    case denied
    case stopped
    case failed
}

extension LocationError: LocalizedError {
    var localizedDescription: String {
        switch self {
        case .denied:
            return "Location access is denied."
        case .stopped:
            return "Location access is required."
        case .failed:
            return "Failed to get location."
        }
    }
}

final class DefaultLocationService: NSObject, LocationService {

    private let locationManager = CLLocationManager()

    private var continuation: CLContinuation?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func setupContinuation(_ continuation: CLContinuation) {
        self.continuation = continuation
    }
    
    func start() {
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
        continuation?.resume(throwing: LocationError.stopped)
        continuation = nil
    }
    
    deinit {
        continuation?.resume(throwing: LocationError.stopped)
        continuation = nil
    }
}

extension DefaultLocationService: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            continuation?.resume(throwing: LocationError.denied)
            continuation = nil
        default:
            break
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let location = locations.first else { return }
        
        manager.stopUpdatingLocation()
        
        continuation?.resume(returning: location)
        continuation = nil
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: any Error
    ) {
        continuation?.resume(throwing: LocationError.denied)
        continuation = nil
    }
}
