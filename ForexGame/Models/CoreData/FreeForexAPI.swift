//
//  FreeForexAPI.swift
//  ForexGame
//
//  Created by Alla on 3/20/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import Foundation
import Moya

enum FreeForexAPI {
    case currentPoint
}

// MARK: - TargetType Protocol Implementation

extension FreeForexAPI: TargetType {
    
}
