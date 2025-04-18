//
//  Models.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import Foundation

struct FileStatus: Identifiable {
    let id = UUID()
    let name: String
    var uncompressedSize: Int = 0
    var compressedSize: Int = 0
    var progress: Double = 0.0
}
extension FileStatus: Sendable {
}
