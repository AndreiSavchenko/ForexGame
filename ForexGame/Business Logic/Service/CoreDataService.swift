//
//  CoreDataService.swift
//  ForexGame
//
//  Created by Alla on 3/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import Foundation
import CoreData

class CoreDataService {

    static let shared = CoreDataService()
    private init() { }
//    var isUpdateChart = false

    //????????????????? обновление контекста как в примере с табле вью 9 урок
    private lazy var context = CoreDataStack.shared.persistentContainer.viewContext

    private lazy var fetchedResultsController: NSFetchedResultsController<Point> = {
        let fetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pointTime", ascending: true)]

//        ???????????

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

//        Проверка на нехватку истории
//        pointsEurusdAll = [1.23440, 1.23443, 1.23444, 1.2345, 1.2346]

        print("pointsEurusdAll = \(pointsEurusdAll) \(pointsEurusdAll.count)")

        if pointsEurusdAll.count>20 {
            let countDelPoints = pointsEurusdAll.count-20
            print("countDelPoints = \(countDelPoints)")
            for _ in 0..<countDelPoints {
//                print("i = \(i)")
                pointsEurusdAll.removeFirst() //?????????????????????? Правильно ли здесь удалять и из контекста
            }
        } else {
            let countAddPoints = 20 - pointsEurusdAll.count
            for _ in 0..<countAddPoints {
                pointsEurusdAll.insert(pointsEurusdAll[0], at: 0)
            }
        }
        pointsEurusd = pointsEurusdAll
        print("pointsEurusd = \(pointsEurusd) \(pointsEurusd.count)")
        return pointsEurusd
    }

//    func updateCartEurusd() {
//        if isUpdateChart { return }
//        isUpdateChart = true
//
//        let timer = Timer(timeInterval: 10.0, target: self, selector: #selector(updateChartWithTimer),
//                          userInfo: nil, repeats: true)
//        RunLoop.current.add(timer, forMode: .common)
//    }
//
//    @objc func updateChartWithTimer(timer: Timer) {
//        let currentDateTime = Date()
//        print("Timer fired!\(currentDateTime)")
//        createArrayPointsEurusd()
//    }
}
