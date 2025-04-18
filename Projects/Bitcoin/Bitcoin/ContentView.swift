//
//  ContentView.swift
//  Bitcoin
//
//  Created by 김건우 on 4/18/25.
//

import SwiftUI

struct ContentView: View {

    @EnvironmentObject var bitcoinViewModel: BitcoinViewModel

    var body: some View {
        VStack {

            Spacer()

            Text("비트코인 현재가:")
                .font(.headline)
                .fontWeight(.bold)

            Group {
                if let coinPrice = bitcoinViewModel.coinPrice {
                    Text("\(coinPrice)원")
                } else {
                    Text("-")
                }
            }
            .font(.title)
            .frame(maxWidth: .infinity, minHeight: 80)
            .foregroundStyle(.white)
            .background(.mint, in: RoundedRectangle(cornerRadius: 25))

            Spacer()

            Button {
                bitcoinViewModel.toggleConnection()
            } label: {
                Group {
                    bitcoinViewModel.connectionStatus
                    ? Text("종료")
                    : Text("시작")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

        }
        .padding()
    }
}

#Preview {
    let bitcoinViewModel = {
        let manager = BitcoinManager()
        let viewModel = BitcoinViewModel(manager: manager)
        return viewModel
    }()

    ContentView()
        .environmentObject(bitcoinViewModel)
}
