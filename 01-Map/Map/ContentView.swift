//
//  ContentView.swift
//  Map
//
//  Created by 김건우 on 3/27/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    
    // MARK: - Properties
    
    @EnvironmentObject var viewModel: MapViewModel
    
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            Map(position: $viewModel.cameraPosition) {
                Marker(
                    viewModel.currentLocation.name,
                    coordinate: viewModel.currentLocation.coordinate
                )
                .tint(.blue)
            }
            .mapStyle(.standard)
            
            VStack {
                Spacer()
                Button("현재 위치 표시하기") {
                    Task {
                        await viewModel.getCurrentLocation()
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom)
            }
        }
        .alert(item: $viewModel.errorMessage) { error in
            Alert(
                title: Text("위치 찾기 실패"),
                message: Text(error),
                primaryButton: .default(Text("확인")),
                secondaryButton: .default(Text("설정 화면으로"), action: {
                UIApplication.shared.open(
                    URL(string: UIApplication.openSettingsURLString)!
                )
            }))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(MapViewModel(locationManager: DefaultLocationService()))
}
