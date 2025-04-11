//
//  ImageDatabase.swift
//  Image
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

@globalActor
actor ImageDatabase {
    
    static let shared = ImageDatabase()
    init() { }
    
    private var storage: DiskStorage!
    private var imageDownloader = ImageDownloader()
    
    private(set) var savedURLs = Set<String>()
    
    func setupInitialData() async throws {
        storage = await DiskStorage()

        if let listItems = try? await storage.listItems() {
            for url in listItems {
                savedURLs.insert(url.lastPathComponent)
            }
        }
    }
    
    
    func image(from url: String) async throws -> Data {
        
        let keys = await imageDownloader.cache.keys
        
        // 메모리 캐시에 이미지가 있다면
        if keys.contains(url) {
            print("🟣 캐시(메모리)에서 이미지 로드함")
            return try await imageDownloader.image(from: url)
        }
        
        do {
            let fileName = DiskStorage.fileName(for: url)
            
            if !savedURLs.contains(fileName) {
                throw URLError(.unknown)
            }
            
            // 디스크 캐시에 이미지가 있다면
            let data = try await storage.read(name: fileName)
            
            await imageDownloader.add(with: data, forURL: url)
            return data
        } catch {
            
            // 메모리와 디스크 캐시에 이미지 데이터가 없다면
            let downloadedData = try await imageDownloader.image(from: url)
            
            try await store(downloadedData, to: url)
            return downloadedData
        }
    }
    
    func store(_ data: Data, to url: String) async throws {
        let fileName = DiskStorage.fileName(for: url)
        
        try await storage.write(data, name: fileName)
        savedURLs.insert(fileName)
    }
}
