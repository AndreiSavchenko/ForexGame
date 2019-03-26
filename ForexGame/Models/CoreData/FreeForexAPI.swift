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
    case currentPoint(pair: String)
}

// MARK: - TargetType Protocol Implementation

extension FreeForexAPI: TargetType {

    var baseURL: URL {
        return URL(string: "https://www.freeforexapi.com/")!
    }

    var path: String {
        switch self {
        case .currentPoint:
            return "api/live"
        }
    }
    var method: Moya.Method {
        switch self {
        case .currentPoint:
            return .get
        }
    }
    var task: Task {
        switch self {
        case let .currentPoint(pair):
            return .requestParameters(parameters: ["pairs": pair], encoding: URLEncoding.queryString)
        }
    }
    var sampleData: Data {
        switch self {
        default:
            return Data()
        }
    }
    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
