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

    func openDeals(currencyPair: String, type: String, timeOpen: NSDate, priceOpen: Double) {

        let deal = Deal(context: self.context)
        deal.currencyPair = currencyPair
        deal.type = type
        deal.timeOpen = timeOpen
        deal.priceOpen = priceOpen
        try? self.context.save()

        print("currencyPair = \(currencyPair)")
        print("type = \(type)")
        print("timeOpen = \(timeOpen)")
        print("priceOpen = \(priceOpen)")
    }

    func closeDeals(timeClose: NSDate, priceClose: Double) {

        try? fetchedResultsController.performFetch()
        guard let lastDeal = fetchedResultsController.fetchedObjects?.last else { return }

        lastDeal.timeClose = timeClose
        lastDeal.priceClose = priceClose
        if lastDeal.type == "Buy" {
            lastDeal.profit = Int32(((priceClose - lastDeal.priceOpen)*1000000))
        } else {
            lastDeal.profit = Int32(((lastDeal.priceOpen - priceClose)*1000000))
        }
        try? self.context.save()

        print("timeClose = \(timeClose)")
        print("priceClose = \(priceClose)")

        print("lastDeal = \(lastDeal)")
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

}
