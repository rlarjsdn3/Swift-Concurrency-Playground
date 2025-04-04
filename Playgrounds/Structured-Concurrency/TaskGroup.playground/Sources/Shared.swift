//
//  Sahred.swift
//  
//
//  Created by 김건우 on 4/4/25.
//

import UIKit

public struct Post {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
extension Post: Decodable {
    enum CodingKeys: String, CodingKey {
        case userId
        case id
        case title
        case body
    }
}
extension Post: Sendable {
}


public func fetchPost(for id: Int) async throws -> Post {
    let url = URL(string: "https://jsonplaceholder.typicode.com/posts/\(id)")!
    
    do {
        try await Task.sleep(for: .seconds(1))
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let post = try? JSONDecoder().decode(Post.self, from: data) else {
            throw URLError(.badURL)
        }
        return post
    } catch {
        if let _ = error as? CancellationError {
            print("⚠️ 작업이 취소되었습니다.")
            throw URLError(.cancelled)
        } else {
            throw URLError(.badURL)
        }
    }
}

public func cachingPost(id: Int) async throws -> Void {
    try await Task.sleep(for: .seconds(1))
    return
}
