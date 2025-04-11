//
//  CompressionUtils.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

enum CompressionUtils {
    
    static func compressFile(
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
}
