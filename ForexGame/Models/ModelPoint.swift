//
//  ModelPoint.swift
//  ForexGame
//
//  Created by Alla on 3/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import Foundation

public struct ModelPoint: Decodable {
    public let rates: Rates
    public let code: Int

//    enum CodingKeys: String, CodingKey {
//        case rates = "rates"
//        case code = "code"
//    }

    public init(rates: Rates, code: Int) {
        self.rates = rates
        self.code = code
    }
}

public struct Rates: Decodable {
    public let eurusd: Eurusd

    enum CodingKeys: String, CodingKey {
        case eurusd = "EURUSD"
    }

    public init(eurusd: Eurusd) {
        self.eurusd = eurusd
    }
}

public struct Eurusd: Decodable {
    public let rate: Double
    public let timestamp: Date

//    enum CodingKeys: String, CodingKey {
//        case rate = "rate"
//        case timestamp = "timestamp"
//    }

    public init(rate: Double, timestamp: Date) {
        self.rate = rate
        self.timestamp = timestamp
    }
}
