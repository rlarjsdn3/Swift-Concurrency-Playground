//
//  ImageDownloader.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import Foundation

protocol ImageDownloader: Sendable {
    func downloadImage(at index: Int) async throws -> Data?
}

actor DefaultImageDownloader: ImageDownloader {

    func downloadImage(at index: Int) async throws -> Data? {
        do {
            // print("ImageDownloader: \(Thread.isMainThread)")
            try await Task.sleep(for: .seconds(1))

            let url = URL(string: appData.items[index])!
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch {
            if let error = error as? URLError, error.code == .cancelled {
                print("🔸작업이 취소됨 (\(index))")
            }
            throw error
        }
    }
}
