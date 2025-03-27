//
//  MapApp.swift
//  Map
//
//  Created by 김건우 on 3/27/25.
//

import SwiftUI

@main
struct MapApp: App {
    
    // MARK: - Properties
    
    let viewModel: MapViewModel = {
        let locationService = DefaultLocationService()
        return MapViewModel(locationManager: locationService)
    }()
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
