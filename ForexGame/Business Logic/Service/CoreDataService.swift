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

    private lazy var context = CoreDataStack.shared.persistentContainer.viewContext

    private lazy var fetchedResultsController: NSFetchedResultsController<Point> = {
        let fetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "pointTime", ascending: false)]
        fetchRequest.fetchLimit = 20
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

    func clearPrevious() {

        try? fetchedResultsController.performFetch() // Fetch new 20

        let current = fetchedResultsController.fetchedObjects ?? [] // 20
        guard current.count == 20 else {
            return
        }

        let currentPointTimes: [NSDate] = current.compactMap { $0.pointTime }

        let deleteFetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
        deleteFetchRequest.sortDescriptors = [NSSortDescriptor(key: "pointTime", ascending: true)]
//        deleteFetchRequest.predicate = NSPredicate(format: "pointTime NOT IN $@", currentPointTimes)
        deleteFetchRequest.predicate = NSPredicate(format: "NOT pointTime IN {%@}", currentPointTimes)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: (deleteFetchRequest as!NSFetchRequest<NSFetchRequestResult>))
        print("deleteRequest = \(deleteRequest)")

//        (NSArray *)result = [context, deleteFetchRequest:fetchRequest error:nil]

//        deleteRequest.executeFetchRequest
//
//        context.delete()
    }

    func createArrayPointsEurusd() -> [Double] {
//        clearPrevious()

        var pointsEurusdAll: [Double] = []
        var pointsEurusd: [Double] = []

        try? fetchedResultsController.performFetch()
        guard let count = fetchedResultsController.fetchedObjects?.count else { return [] }
        for i in 0..<count {
            pointsEurusdAll.append((fetchedResultsController.fetchedObjects?[i].pointPrice)!)
        }
        pointsEurusdAll.reverse()

//        Проверка на нехватку истории
//        pointsEurusdAll = [1.23440, 1.23443, 1.23444, 1.2345, 1.2346]

        if pointsEurusdAll.count<20 {
            let countAddPoints = 20 - pointsEurusdAll.count
            for _ in 0..<countAddPoints {
                pointsEurusdAll.insert(pointsEurusdAll[0], at: 0)
            }
        }

        pointsEurusd = pointsEurusdAll
//        print("pointsEurusd = \(pointsEurusd) \(pointsEurusd.count)")
        return pointsEurusd
    }

}
