//
//  ContentView.swift
//  FileCompressor
//
//  Created by 김건우 on 4/11/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = CompressionState()
    
    var body: some View {
        NavigationStack {
            List(manager.files) { file in
                CompressionView(file: file)
            }
            .navigationTitle("파일 압축")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("압축 시작") {
                        manager.compressAllFiles()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
