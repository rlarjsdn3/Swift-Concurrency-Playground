//
//  ImageDownloader.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import Foundation

actor ImageDownloader {

    enum CacheEntry {
        case completed(Data)
        case inProgress(Task<Data, Error>)
    }
    
    var cache: [String: CacheEntry] = [:]
    
    func image(from url: String) async throws -> Data {
        if let cacheEntry = cache[url] {
            switch cacheEntry {
            case .completed(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        
        let task = Task<Data, Error> {
            do {
                guard let url = URL(string: url) else {
                    throw URLError(.badURL)
                }
                let (data, _) = try await URLSession.shared.data(from: url)
                return data
            } catch {
                throw URLError(.unknown)
            }
        }
        
        cache[url] = .inProgress(task)
        
        do {
            let image = try await task.value
            cache[url] = .completed(image)
            return image
        } catch {
            cache[url] = nil
            throw error
        }
    }
    
    func add(with data: Data, forURL url: String) {
        cache[url] = .completed(data)
    }
}
