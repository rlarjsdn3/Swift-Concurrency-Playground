//
//  CompressionState.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

@MainActor
class CompressionState: ObservableObject {
    
    var compressor: CompressionUtils!
    
    @Published var files: [FileStatus] = [
        FileStatus(name: "Sample1.mp4", uncompressedSize: 15),
        FileStatus(name: "Document.pdf", uncompressedSize: 20),
        FileStatus(name: "Image.png", uncompressedSize: 12),
        FileStatus(name: "Archive.zip", uncompressedSize: 50),
        FileStatus(name: "Image2.png", uncompressedSize: 10),
        FileStatus(name: "폴더압축.zip", uncompressedSize: 50),
        FileStatus(name: "Archive2.zip", uncompressedSize: 40)
    ]
    
    init() {
        compressor = CompressionUtils(state: self)
    }
    
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
            // 💡 작업 병렬 처리
            // `Task.detached`를 사용하여 메인 스레드와 분리된 백그라운드에서 병렬로 실행합니다.
            // `Task`는 MainActor를 상속받기 때문에 순차적으로 동작하며, UI 업데이트가 지연될 수 있습니다.
            // 반면 `Task.detached`는 각 파일 압축 작업을 동시에 실행하고, 완료되는 대로 개별적으로 저장 및 UI 업데이트가 가능합니다.
            
            Task.detached {
                let compressedData = await self.compressor.compress(with: file)
                await self.save(compressedData, to: file.name)
            }
        }
    }
    
    
    
    func save(_ data: Data, to name: String) async {
        await compressor.log(update: "압축된 파일 저장: \(name)")
        // ...
    }
}
