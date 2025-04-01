//
//  ApplicationData.swift
//  Image
//
//  Created by 김건우 on 4/1/25.
//

import Foundation

final class ApplicationData {
    
    let items: [String]
    
    init?() {
        guard
            let url = Bundle.main.url(forResource: "Photos", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let items = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String]
        else { return nil }
        
        self.items = items
    }
}
nonisolated(unsafe) let appData = ApplicationData()!
