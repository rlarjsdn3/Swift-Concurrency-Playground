//
//  DiskStorage.swift
//  Image
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

@ImageDatabase
final class DiskStorage {
    
    private let fileManager = FileManager.default
    
    private var folder: URL
    
    init() {
        guard let downloadsURL = fileManager.urls(
            for: .downloadsDirectory,
            in: .userDomainMask).first else {
            fatalError("🔴 다운로드 폴더 접근 불가")
        }
        
        let folderURL = downloadsURL.appending(path: "database", directoryHint: .isDirectory)
        
        do {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        } catch {
            fatalError("🔴 하위 폴더 생성 실패")
        }
        
        folder = folderURL
    }
    
    nonisolated static func fileName(for path: String) -> String {
        return path.dropFirst()
            .components(separatedBy: .punctuationCharacters)
            .joined(separator: "-")
    }
    
    func read(name: String) throws -> Data {
        return try Data(contentsOf: folder.appending(path: name))
    }
    
    func write(_ data: Data, name: String) throws {
        try data.write(to: folder.appending(path: name), options: .atomic)
    }
    
    func remove(name: String) throws {
        try fileManager.removeItem(at: folder.appending(path: name))
    }
    
    func listItems() throws -> [URL] {
        var urls: [URL] = []
        guard let directoryEnumerator = fileManager.enumerator(
            at: folder,
            includingPropertiesForKeys: []
        ) else {
            throw URLError(.unknown)
        }
        
        for url in directoryEnumerator.allObjects {
            urls.append(url as! URL)
        }
        return urls
    }
}
