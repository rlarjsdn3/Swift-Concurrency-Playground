//
//  MapViewModel.swift
//  Map
//
//  Created by 김건우 on 3/27/25.
//

import Foundation
import _MapKit_SwiftUI

final class MapViewModel: ObservableObject {
    
    // MARK: - Typealias
    
    typealias Location = (name: String, coordinate: CLLocationCoordinate2D)
    
    // MARK: - Properties
    
    private let locationManager: any LocationService
    
    @Published private(set) var currentLocation: Location = ("서울 시청", .cityHall)
    
    @Published var cameraPosition: MapCameraPosition = .region(.userRegion)
    
    @Published var errorMessage: String?
    
    // MARK: - Initalizer
    
    init(locationManager: LocationService) {
        self.locationManager = locationManager
    }
    
    // MARK: - Get Current Location
    
    func getCurrentLocation() async {
        do {
            let location: CLLocation = try await withCheckedThrowingContinuation { [weak self] continuation in

                self?.locationManager.setupContinuation(continuation)
                self?.locationManager.start()
            }
            
            await MainActor.run {
                self.currentLocation = ("현재 위치", location.coordinate)
                self.cameraPosition = .region(
                    .init(center: location.coordinate,
                          latitudinalMeters: 1_000,
                          longitudinalMeters: 1_000)
                )
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
        }
    }
    
}


extension CLLocationCoordinate2D {
    /// 서울 시청의 위도와 경도
    static var cityHall: CLLocationCoordinate2D {
        return .init(latitude: 37.5665851, longitude: 126.9782038)
    }
}

extension MKCoordinateRegion {
    
    static var userRegion: MKCoordinateRegion {
        return .init(center: .cityHall, latitudinalMeters: 1_000, longitudinalMeters: 1_000)
    }
}


extension String: @retroactive Identifiable {
    public var id: String {
        return self
    }
}
