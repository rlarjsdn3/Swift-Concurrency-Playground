//
//  MapTests.swift
//  MapTests
//
//  Created by 김건우 on 3/27/25.
//

import CoreLocation
import XCTest

@testable import Map

final class MapViewModelTests: XCTestCase {

    func testMapViewModel_GettingCurrentLocation_thenSuccess() async {
        // given
        let locationService = MockLocationService()
        let viewModel = MapViewModel(locationManager: locationService)
        
        let expectedLocation = CLLocation(latitude: 12.345, longitude: 45.678)
        locationService.simulatedLocation = expectedLocation

        // when
        await viewModel.getCurrentLocation()

        // then
        XCTAssertEqual(viewModel.currentLocation.name, "현재 위치")
        XCTAssertEqual(
            viewModel.currentLocation.coordinate,
            expectedLocation.coordinate
        )
        XCTAssertEqual(
            viewModel.cameraPosition,
            .region(
                .init(center: expectedLocation.coordinate,
                      latitudinalMeters: 1_000,
                      longitudinalMeters: 1_000)
            )
        )
    }
    
    func testMapViewModel_GettingCurrentLocation_thenFail() async {
        // given
        let locationService = MockLocationService()
        let viewModel = MapViewModel(locationManager: locationService)
        
        let expectedError = LocationError.denied
        locationService.simulatedError = expectedError
        
        // when
        await viewModel.getCurrentLocation()
        
        // then
        XCTAssertEqual(viewModel.errorMessage, "The operation couldn’t be completed. (Map.LocationError error 0.)")
    }

}

extension CLLocationCoordinate2D: @retroactive Equatable {

    public static func == (
        lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D
    ) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
