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
        guard current.count == 20 else { return }
        let currentPointTimes: [NSDate] = current.compactMap { $0.pointTime }

        let deleteFetchRequest: NSFetchRequest<Point> = Point.fetchRequest()
        deleteFetchRequest.sortDescriptors = [NSSortDescriptor(key: "pointTime", ascending: true)]
        deleteFetchRequest.predicate = NSPredicate(format: "NOT pointTime IN %@", currentPointTimes)
        let deleteBatchRequest = NSBatchDeleteRequest(fetchRequest:
            (deleteFetchRequest as! NSFetchRequest<NSFetchRequestResult>))

        do {
            try context.execute(deleteBatchRequest)
        } catch {
            print("Error")
        }
    }

    func createArrayPointsEurusd() -> [Double] {
        clearPrevious()

        var pointsEurusdAll: [Double] = []

        try? fetchedResultsController.performFetch()
        guard let count = fetchedResultsController.fetchedObjects?.count, count > 0 else { return [] }
//        print("count = \(count)")
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
        return pointsEurusdAll
    }

    func lastPrice() -> Double {
        try? fetchedResultsController.performFetch()
        guard let countObject = fetchedResultsController.fetchedObjects?.count, countObject > 0 else { return 0 }
        let lastObject = fetchedResultsController.fetchedObjects?.first
        let lastPrice = lastObject?.pointPrice
        return lastPrice ?? 0
    }

}
