//
//  RoundDouble.swift
//  ForexGame
//
//  Created by Alla on 3/29/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import Foundation

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}
