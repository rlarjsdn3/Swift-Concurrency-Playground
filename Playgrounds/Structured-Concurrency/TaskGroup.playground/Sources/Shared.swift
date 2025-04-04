//
//  Sahred.swift
//  
//
//  Created by 김건우 on 4/4/25.
//

import UIKit

public let url = "https://picsum.photos/200/300?grayscale"

public func downloadImage(from url: String) async throws -> UIImage {
    let url = URL(string: url)!
    
    do {
        try await Task.sleep(for: .seconds(1))
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            throw URLError(.cannotDecodeContentData)
        }
        return image
    } catch {
        if let _ = error as? CancellationError {
            print("⚠️ 작업이 취소되었습니다.")
            throw URLError(.cancelled)
        } else {
            throw URLError(.badURL)
        }
    }
}
