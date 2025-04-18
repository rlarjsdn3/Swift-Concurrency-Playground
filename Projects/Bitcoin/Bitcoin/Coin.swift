//
//  Coin.swift
//  Bitcoin
//
//  Created by 김건우 on 4/18/25.
//

import Foundation

struct Coin: Decodable {
    let tradePrice: Int
}
extension Coin {
    private enum CodingKeys: String, CodingKey {
        case tradePrice = "trade_price"
    }
}
