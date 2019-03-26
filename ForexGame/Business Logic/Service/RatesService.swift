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

    let provider = MoyaProvider<FreeForexAPI>()                             //(plugins: [NetworkLoggerPlugin()])
    let context = CoreDataStack.shared.persistentContainer.viewContext
    var isWorking = false
//    var isUpdateChart = true

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
                    point.pointPrice = currPoint.rates.eurusd.rate
                    point.pointTime = currPoint.rates.eurusd.timestamp as NSDate
                    try? self.context.save()
                } catch let error {
                    debugPrint("success ERROR = \(error)")
                }
            case .failure(let error):
                debugPrint("failure ERROR = \(error)")
            }
        }
    }

    private lazy var fetchedResultsController: NSFetchedResultsController<Point> = {
        let fetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pointTime", ascending: true)]
        let controller = NSFetchedResultsController<Point>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self as? NSFetchedResultsControllerDelegate
        try? controller.performFetch()
        return controller
    }()

    func createArrayPointsEurusd() -> [Double] {

        var pointsEurusdAll: [Double] = []
        var pointsEurusd: [Double] = []

        guard let count = fetchedResultsController.fetchedObjects?.count else { return [] }
        for i in 0..<count {
            pointsEurusdAll.append((fetchedResultsController.fetchedObjects?[i].pointPrice)!)

        }

        print("pointsEurusdAll = \(pointsEurusdAll) \(pointsEurusdAll.count)")

        if pointsEurusdAll.count>20 {
            let countDelPoints = pointsEurusdAll.count-20
            print("countDelPoints = \(countDelPoints)")
            for _ in 0..<countDelPoints {
                //                print("i = \(i)")
                pointsEurusdAll.removeFirst()
            }
            pointsEurusd = pointsEurusdAll
        }

        print("pointsEurusd = \(pointsEurusd) \(pointsEurusd.count)")
        return pointsEurusd
    }

    func downloadPointsToCoreData() {
        if isWorking { return }
        isWorking = true

        let timer = Timer(timeInterval: 10.0, target: self, selector: #selector(getPointFromAPIWithTimer),
                          userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .common)
    }

    @objc func getPointFromAPIWithTimer(timer: Timer) {
        let currentDateTime = Date()
        print("Timer fired!\(currentDateTime)")
        savePointFromAPI()
        createArrayPointsEurusd()
    }
}
