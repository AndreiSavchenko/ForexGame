//
//  Deals.swift
//  ForexGame
//
//  Created by Alla on 3/28/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import Foundation
import CoreData

class Deals {

    static let shared = Deals()
    private init() { }

    let coreDataService = CoreDataService.shared
    let context = CoreDataStack.shared.persistentContainer.viewContext

    // MARK: - fetchedResultsController LAST DEAL

    private lazy var fetchedResultsController: NSFetchedResultsController<Deal> = {
        let fetchRequest: NSFetchRequest<Deal> = Deal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeOpen", ascending: false)]
        fetchRequest.fetchLimit = 1
        let controller = NSFetchedResultsController<Deal>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self as? NSFetchedResultsControllerDelegate
        try? controller.performFetch()
        return controller
    }()

    // MARK: - fetchedResultsController AllClose

    private lazy var fetchedResultsControllerAllClose: NSFetchedResultsController<Deal> = {
        let fetchRequest: NSFetchRequest<Deal> = Deal.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeClose", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "timeClose != nil")
        let controller = NSFetchedResultsController<Deal>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self as? NSFetchedResultsControllerDelegate
        try? controller.performFetch()
        return controller
    }()

    // MARK: - SAVE COREDATA OPENED PROPERTIES DEAL

    func openDeals(currencyPair: String, type: String, timeOpen: NSDate, priceOpen: Double) {
        let deal = Deal(context: self.context)
        deal.currencyPair = currencyPair
        deal.type = type
        deal.timeOpen = timeOpen
        deal.priceOpen = priceOpen
        if getBalance() > 0 {
            deal.balanceFix = getBalance()
        } else {
            deal.balanceFix = 10000
        }
        print("deal = \(deal)")
        try? self.context.save()
    }

    // MARK: - SAVE COREDATA CLOSED PROPERTIES DEAL

    func closeDeals(timeClose: NSDate, priceClose: Double) {
        try? fetchedResultsController.performFetch()
        guard let lastDeal = fetchedResultsController.fetchedObjects?.last else { return }
        lastDeal.timeClose = timeClose
        lastDeal.priceClose = priceClose
        if lastDeal.type == "Buy" {
            lastDeal.profit = Int32(((priceClose - lastDeal.priceOpen)*1000000))
            lastDeal.balanceFix += Int32(((priceClose - lastDeal.priceOpen)*1000000))
        } else {
            lastDeal.profit = Int32(((lastDeal.priceOpen - priceClose)*1000000))
            lastDeal.balanceFix += Int32(((lastDeal.priceOpen - priceClose)*1000000))
        }
        try? self.context.save()
    }

    // MARK: - ADDITIONAL FUNC FOR DEALS

    func getAllCloseDeals() -> [Deal] {
        try? fetchedResultsControllerAllClose.performFetch()
        guard let arrDeals = fetchedResultsControllerAllClose.fetchedObjects else { return [] }
        guard let countDeals = fetchedResultsControllerAllClose.fetchedObjects?.count, countDeals > 0 else { return [] }
        //        for i in 0 ..< countDeals {
        //            print("profit \(i) = \(arrDeals[i].timeClose)")
        //        }
        print(countDeals)
        return arrDeals
    }

    func currProfit() -> Int32 {
        try? fetchedResultsController.performFetch()
        guard let lastDeal = fetchedResultsController.fetchedObjects?.last else { return 0 }

        if lastDeal.type == "Buy" {
            lastDeal.profit = Int32(((coreDataService.lastPrice() - lastDeal.priceOpen)*1000000))
        } else {
            lastDeal.profit = Int32(((lastDeal.priceOpen - coreDataService.lastPrice())*1000000))
        }
        return lastDeal.profit
    }

    func isOpenDeal() -> Bool {
        try? fetchedResultsController.performFetch()
        guard let lastDeal = fetchedResultsController.fetchedObjects?.last else { return false }
        var isOpenDeal: Bool = false
        if lastDeal.timeOpen != nil && lastDeal.timeClose == nil {
            isOpenDeal = true
        }
        return isOpenDeal
    }

    func priceOpenDeal() -> Double {
        try? fetchedResultsController.performFetch()
        guard let lastDeal = fetchedResultsController.fetchedObjects?.last else { return 0 }
        return lastDeal.priceOpen
    }

    func typeOpenDeal() -> String {
        try? fetchedResultsController.performFetch()
        guard let lastDeal = fetchedResultsController.fetchedObjects?.last else { return "" }
        return lastDeal.type ?? ""
    }

    func getBalance() -> Int32 {
        try? fetchedResultsControllerAllClose.performFetch()
        guard let lastDeal = fetchedResultsControllerAllClose.fetchedObjects?.first else { return 0 }
        return lastDeal.balanceFix
    }

    func clearAllDeals() {
        try? fetchedResultsControllerAllClose.performFetch()
        let deleteFetchRequest: NSFetchRequest<Deal> = Deal.fetchRequest()
        deleteFetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeClose", ascending: true)]
        let deleteBatchRequest = NSBatchDeleteRequest(fetchRequest:
            (deleteFetchRequest as! NSFetchRequest<NSFetchRequestResult>))

        do {
            try context.execute(deleteBatchRequest)
        } catch {
            print("Error")
        }
    }
}
