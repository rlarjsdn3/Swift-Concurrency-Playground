//
//  CompressionUtils.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

actor CompressionUtils {
    
    // 로그 상태를 저장하는 배열
    var logs: [String] = []
    
    unowned var state: CompressionState
    
    init(state: CompressionState) {
        self.state = state
    }
    
    
    // 💡 액터 경합 방지(Avoid Actor Contention)
    // `compress(with:)` 메서드를 비격리(nonisolated)로 선언한 이유는, 각 작업이 액터의 컨텍스트에 머무는 시간을 최소화하여
    // 로그 저장 등 꼭 필요한 순간에만 잠시 액터에 접근하도록 하여 성능을 최적화하기 위함입니다.
    // 액터는 한 번에 하나의 작업만 처리할 수 있으므로, 각 작업의 범위를 가능한 작게 유지해
    // 다른 작업이 원활하게 액터에 접근할 수 있도록 해야 합니다.
    nonisolated func compress(with file: FileStatus) async -> Data {
        await log(update: "🔴 압축 시작: \(file.name)")
        let compressedData = compressFile(
            for: file) { size in
                Task { @MainActor in
                    await state.update(name: file.name, uncompressedSize: size)
                }
            } progressNotification: { progress in
                Task { @MainActor in
                    await state.update(name: file.name, progress: progress)
                }
            } finalNotification: { size in
                Task { @MainActor in
                    await state.update(name: file.name, compressedSize: size)
                }
            }
        await log(update: "🔵 압축 완료: \(file.name)")
        
        return compressedData
    }
    
    // 💡 마찬가지로, 비격리 메서드로 선언함으로써
    // 파일 압축 작업이 액터의 컨텍스트에 머무는 시간을 최소화합니다.
    nonisolated func compressFile(
        for file: FileStatus,
        uncompressedNotification: (Int) -> Void,
        progressNotification: (Double) -> Void,
        finalNotification: (Int) -> Void
    ) -> Data {
        
        uncompressedNotification(file.uncompressedSize)
        
        sleep(UInt32.random(in: 1...3))
        progressNotification(0.25)
        sleep(UInt32.random(in: 1...3))
        progressNotification(0.50)
        sleep(UInt32.random(in: 1...3))
        progressNotification(0.75)
        sleep(UInt32.random(in: 1...3))
        progressNotification(1.0)
        
        let compressedSize = file.compressedSize
        finalNotification(compressedSize)
        
        return Data()
    }
    
    func log(update: String) {
        print(update)
        logs.append(update)
    }
}
