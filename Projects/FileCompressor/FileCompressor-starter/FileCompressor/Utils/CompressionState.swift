//
//  CompressionState.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

@MainActor
class CompressionState: ObservableObject {
    
    @Published var files: [FileStatus] = [
        FileStatus(name: "Sample1.mp4", uncompressedSize: 15),
        FileStatus(name: "Document.pdf", uncompressedSize: 20),
        FileStatus(name: "Image.png", uncompressedSize: 12),
        FileStatus(name: "Archive.zip", uncompressedSize: 50),
        FileStatus(name: "Image2.png", uncompressedSize: 10),
        FileStatus(name: "폴더압축.zip", uncompressedSize: 50),
        FileStatus(name: "Archive2.zip", uncompressedSize: 40)
    ]
    
    // 로그 상태를 저장하는 배열
    var logs: [String] = []
    
    // 파일 압축 전, 압축하기 전 크기로 업데이트
    func update(name: String, uncompressedSize: Int) {
        if let loc = files.firstIndex(where: { $0.name == name }) {
            files[loc].uncompressedSize = uncompressedSize
        }
    }
    
    // 파일 압축 중, 압축 진행률 업데이트
    func update(name: String, progress: Double) {
        if let loc = files.firstIndex(where: { $0.name == name }) {
            files[loc].progress = progress
        }
    }
    
    // 파일 압축 후, 압축된 크기로 업데이트
    func update(name: String, compressedSize: Int) {
        if let loc = files.firstIndex(where: { $0.name == name }) {
            files[loc].compressedSize = compressedSize
        }
    }
    
    
    // 모든 파일 압축하기
    func compressAllFiles() {
        for file in files {
            //
            
            Task { // @MainActor in
                let compressedData = compress(with: file)
                await save(compressedData, to: file.name)
            }
        }
    }
    
    func compress(with file: FileStatus) -> Data {
        log(update: "🔴 압축 시작: \(file.name)")
        let compressedData = CompressionUtils.compressFile(
            for: file) { size in
                update(name: file.name, uncompressedSize: size)
            } progressNotification: { progress in
                update(name: file.name, progress: progress)
            } finalNotification: { size in
                update(name: file.name, compressedSize: size)
            }
        return compressedData
    }
    
    
    
    func save(_ data: Data, to name: String) async {
        log(update: "압축된 파일 저장: \(name)")
        // ...
    }
    
    func log(update: String) {
        print(update)
        logs.append(update)
    }
    
    
}
