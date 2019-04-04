//
//  RatesService.swift
//  ForexGame
//
//  Created by Alla on 3/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import Foundation
import Moya
import CoreData

class RatesService {

    static let shared = RatesService()
    private init() { }

    let provider = MoyaProvider<FreeForexAPI>()          // additional info - (plugins: [NetworkLoggerPlugin()])
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var isWorking = false
    var isUpdateChart = true
    var onPricesUpdated: (() -> Void)?

    // MARK: - SAVE POINT FROM API AND UPDATED

    func savePointFromAPI() {
        provider.request(.currentPoint(pair: "EURUSD")) { (result) in
            switch result {
            case .success(let response):
                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .millisecondsSince1970
                    let currPoint: ModelPoint = try filteredResponse.map(ModelPoint.self, using: decoder)
                    //print("1 POINT = \(currPoint)")

                    let point = Point(context: self.context)
                    point.pointPrice = currPoint.rates.eurusd.rate.roundToDecimal(5)
//                    print("NEW PRICE = \(point.pointPrice)")
                    point.pointTime = currPoint.rates.eurusd.timestamp as NSDate
//                    print("NEW TIME = \(String(describing: point.pointTime))")
                    try? self.context.save()
                    self.onPricesUpdated?()
                } catch let error {
                    debugPrint("success ERROR = \(error)")
                }
            case .failure(let error):
                debugPrint("failure ERROR = \(error)")
            }
        }
    }

    // MARK: - TIMER FOR SAVE POINT FROM API

    func downloadPointsToCoreData() {
        if isWorking { return }
        isWorking = true

        let timer = Timer(timeInterval: 30.0, target: self, selector: #selector(getPointFromAPIWithTimer),
                          userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }

    // Selector Timer
    @objc func getPointFromAPIWithTimer(timer: Timer) {
//        let currentDateTime = Date()
//        print("Timer ++++++++++++++++++++++++++++++\(currentDateTime)")
        savePointFromAPI()
    }
}
