//
//  LocationViewModel.swift
//  LocationApp
//
//  Created by 김건우 on 4/12/25.
//

import CoreLocation
import Foundation

@MainActor
final class LocationViewModel: ObservableObject {
    
    private let locationService: LocationService
    
    private var locationStream: AsyncThrowingStream<CLLocation, Error>?
    
    @Published var location = CLLocation(latitude: 0, longitude: 0)
    
    @Published var errorMessage: String? = nil
    
    init(locationService: LocationService) {
        self.locationService = locationService
    }
    
    func startUpdateLocation() async {
        locationStream = AsyncThrowingStream(
            CLLocation.self,
            bufferingPolicy: .bufferingNewest(1)
        ) { [weak self] continuation in
            
            continuation.onTermination = { @Sendable [weak self] _ in
                self?.locationService.stop()
            }
            
            self?.locationService.setupContinuation(continuation)
            self?.locationService.start()
        }
        
        guard let locationStream else {
            return
        }
        
        do {
            for try await location in locationStream {
                print("🟠 위치 정보 갱신: \(location)")
                self.location = location
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func stopUpdateLocation() {
        self.location = CLLocation(latitude: 0, longitude: 0)
        self.locationService.stop()
        self.locationStream = nil
    }
}


extension String: @retroactive Identifiable {
    public var id: Self { self }
}
