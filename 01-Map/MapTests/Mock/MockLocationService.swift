//
//  MockLocationService.swift
//  MapTests
//
//  Created by 김건우 on 3/27/25.
//

import CoreLocation
import Foundation
@testable import Map

final class MockLocationService: NSObject, LocationService {
    
    private(set) var continuation: CLContinuation?
    
    var simulatedLocation: CLLocation?
    var simulatedError: (any Error)?
    
    func setupContinuation(_ continuation: CLContinuation) {
        self.continuation = continuation
        
        if let location = simulatedLocation {
            self.continuation?.resume(returning: location)
        } else if let error = simulatedError {
            self.continuation?.resume(throwing: error)
        }
    }
    
    func start() { }
    
    func stop() {
        continuation?.resume(throwing: CLError(.denied))
        continuation = nil
    }
}


