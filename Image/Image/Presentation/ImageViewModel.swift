//
//  ImageViewModel.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import Foundation

@MainActor final class ImageViewModel {
    
    // MARK: - Properties
    
    private let imageDownloader: ImageDownloader
    
    private var imageTasks: [IndexPath: Task<Data?, Never>] = [:]
    
    // MARK: - Intializer
    
    init(imageDownloader: ImageDownloader) {
        self.imageDownloader = imageDownloader
    }
}

extension ImageViewModel {
    
    func downloadImage(at indexPath: IndexPath) async -> Data? {
        if let existingTask = imageTasks[indexPath] {
            return await existingTask.value
        }
        
        let task = Task {
            defer { imageTasks[indexPath] = nil }
            return try? await imageDownloader.downloadImage(at: indexPath.row)
        }
        
        imageTasks[indexPath] = task
        return await task.value
    }
    
    func cancel(at indexPath: IndexPath) {
        imageTasks[indexPath]?.cancel()
        imageTasks[indexPath] = nil
    }
}
