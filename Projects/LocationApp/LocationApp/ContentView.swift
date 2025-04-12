//
//  ContentView.swift
//  LocationApp
//
//  Created by 김건우 on 4/12/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: LocationViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("나의 위치 실시간 확인하기")
                .font(.title3)
                .padding()
            Text("위도: \(viewModel.location.coordinate.latitude)")
                .font(.title)
            Text("경도: \(viewModel.location.coordinate.longitude)")
                .font(.title)
            
            Spacer()
            
            HStack {
                Button("위치 업데이트 시작") {
                    Task {
                        await viewModel.startUpdateLocation()
                    }
                }
                .buttonStyle(.borderedProminent)
                
                Button("위치 업데이트 종료") {
                    viewModel.stopUpdateLocation()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .alert(item: $viewModel.errorMessage) { message in
            Alert(
                title: Text("에러 발생"),
                message: Text(message),
                primaryButton: .default(Text("확인")),
                secondaryButton: .default(Text("Setting으로"), action: {
                    UIApplication.shared.open(
                        URL(string: UIApplication.openSettingsURLString)!
                    )
                })
            )
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationViewModel(locationService: LocationService()))
}
