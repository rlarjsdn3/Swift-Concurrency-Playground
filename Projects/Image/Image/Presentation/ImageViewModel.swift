//
//  ImageViewModel.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import Foundation

@MainActor final class ImageViewModel {
    
    // MARK: - Properties
    
    private let imageDatabase: ImageDatabase
    
    private var imageURLs: [String] = []
    private var imageTasks: [IndexPath: Task<Data?, Never>] = [:]
    
    // MARK: - Intializer
    
    init(imageDatabase: ImageDatabase) {
        self.imageDatabase = imageDatabase
        
        _ = loadURLs()
    }
}

extension ImageViewModel {
    
    private func loadURLs() -> [String] {
        guard let url = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
              let contents = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: contents, format: nil),
              let imageURLs = plist as? [String] else {
            return []
        }
        
        self.imageURLs = imageURLs
        return imageURLs
    }
    
    func downloadImage(at indexPath: IndexPath) async -> Data? {
        if let existingTask = imageTasks[indexPath] {
            return await existingTask.value
        }
        
        let task = Task {
            defer { imageTasks[indexPath] = nil }
            return try? await imageDatabase.image(from: imageURLs[indexPath.row])
        }
        
        imageTasks[indexPath] = task
        return await task.value
    }
    
    func cancel(at indexPath: IndexPath) {
        imageTasks[indexPath]?.cancel()
        imageTasks[indexPath] = nil
    }
}
