//
//  CompressionView.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import SwiftUI

struct CompressionView: View {
    let file: FileStatus
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(file.name)
                .font(.headline)
            Text("Size: \(file.uncompressedSize) MB")
                .font(.subheadline)
            
            ProgressView(value: file.progress)
        }
    }
}

#Preview {
    CompressionView(file: FileStatus(name: "MyFile.zip", uncompressedSize: 15))
}
