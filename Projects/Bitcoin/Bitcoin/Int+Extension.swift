//
//  Int+Extension.swift
//  Bitcoin
//
//  Created by 김건우 on 4/18/25.
//

import Foundation

extension Int {
    func formatter(_ numberStyle: NumberFormatter.Style = .decimal) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = numberStyle
        return formatter.string(from: NSNumber(value: self))
    }
}
