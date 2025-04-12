//
//  LocationAppApp.swift
//  LocationApp
//
//  Created by 김건우 on 4/12/25.
//

import SwiftUI

@main
struct LocationApp: App {
    let locationViewModel = LocationViewModel(locationService: LocationService())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationViewModel)
        }
    }
}
