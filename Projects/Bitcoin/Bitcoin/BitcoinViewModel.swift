//
//  BitcoinViewModel.swift
//  Bitcoin
//
//  Created by 김건우 on 4/18/25.
//

import Foundation

let url = URL(string: "wss://api.upbit.com/websocket/v1")!

@MainActor
final class BitcoinViewModel: ObservableObject {

    // MARK: - Properties

    private let manager: BitcoinManager

    @Published private var coin: Coin?
    @Published private(set) var connectionStatus = false

    var coinPrice: String? {
        coin?.tradePrice.formatter()
    }


    // MARK: - Intializer

    init(manager: BitcoinManager) {
        self.manager = manager
    }


    // MARK: - Toggle

    func toggleConnection() {
        connectionStatus.toggle()
        connectionStatus ? startFetchingBitcoinData() : stopFetchingBitcoinData()
    }


    // MARK: - Private

    private func startFetchingBitcoinData() {
        Task {
            await self.manager.connect(from: url)

            guard let stream = manager.stream else { return }

            for try await message in stream {
                handleMessage(message)
            }
        }
    }

    private func stopFetchingBitcoinData() {
        manager.disconnect()
    }

    private func handleMessage(_ message: URLSessionWebSocketTask.Message) {
        switch message {
        case .data(let data):
            do {
                let coin = try JSONDecoder().decode(Coin.self, from: data)
                print("✅ 비트코인 현재가: \(coin.tradePrice)")
                self.coin = coin
            } catch {
                print("🔴 JSON 파싱 에러")
            }
        case .string(let string):
            print("✅ 웹소켓 string: \(string)")
        @unknown default:
            print("✅ 알 수 없는 웹소켓 처리")
        }
    }
}
