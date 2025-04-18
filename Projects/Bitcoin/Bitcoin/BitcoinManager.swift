//
//  BitcoinManager.swift
//  Bitcoin
//
//  Created by 김건우 on 4/18/25.
//

import Foundation

enum BitcoinError: Error {
    case noMessage
}

@MainActor
final class BitcoinManager: NSObject {

    // MARK: - Properties

    private var webSocketTask: URLSessionWebSocketTask? // Stored property 'webSocketTask' of 'Sendable'-conforming class 'BitcoinManager' is mutable
    private var isActive = false

    typealias BitcoinStream = AsyncThrowingStream<URLSessionWebSocketTask.Message, Error>
    private var continuation: BitcoinStream.Continuation?

    private(set) var stream: BitcoinStream?

    private var timer: Timer?


    // MARK: - Connect

    func connect(from url: URL) async {
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()

        checkingAlive()
        await sendPing()
    }


    // MARK: - Disconnect

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil

        timer?.invalidate()
        timer = nil

        isActive = false
    }



    // MARK: - Private

    private func receiveMessage() async {
        isActive = true

        stream = BitcoinStream { continuation in
            self.continuation = continuation
        }

        while isActive && webSocketTask?.closeCode == .invalid {
            do {
                let message = try await webSocketTask?.receive()

                guard let message = message else {
                    continuation?.yield(with: .failure(BitcoinError.noMessage))
                    self.disconnect()
                    break
                }

                continuation?.yield(with: .success(message))
            } catch {
                print("🔴 메시지 수신 실패: \(error)")
                continuation?.yield(with: .failure(error))
                self.disconnect()
            }
        }

        stream = nil
        continuation?.finish()
        continuation = nil
    }

    private func checkingAlive() {
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { await self?.sendPing() }
        }
    }

    private func sendPing() async {
        let requestFormat = "[{ticket:test},{type:ticker,codes:[KRW-BTC]}]"

        do {
            try await webSocketTask?.send(.string(requestFormat))
            print("🔵 핑(Ping) 전송 성공")
        } catch {
            print("🔴 핑(Ping) 전송 실패")
        }
    }
}

extension BitcoinManager: URLSessionWebSocketDelegate {

    nonisolated func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didOpenWithProtocol protocol: String?) {
        print("🟠 웹 소켓 연결 시작")
        Task { await receiveMessage() }
    }

    nonisolated func urlSession(_ session: URLSession,
                    webSocketTask: URLSessionWebSocketTask,
                    didCloseWith closeCode: URLSessionWebSocketTask.CloseCode,
                    reason: Data?) {
        print("🟠 웹 소켓 연결 종료")
        Task { await self.disconnect() }
    }
}
