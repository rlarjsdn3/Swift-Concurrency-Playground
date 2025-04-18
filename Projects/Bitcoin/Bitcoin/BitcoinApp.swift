//
//  BitcoinApp.swift
//  Bitcoin
//
//  Created by 김건우 on 4/18/25.
//

import SwiftUI

@main
struct BitcoinApp: App {

    @StateObject var bitcoinViewModel = {
        let manager = BitcoinManager()
        let viewModel = BitcoinViewModel(manager: manager)
        return viewModel
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(bitcoinViewModel)
        }
    }
}
