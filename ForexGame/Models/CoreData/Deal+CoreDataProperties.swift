//
//  Deal+CoreDataProperties.swift
//  ForexGame
//
//  Created by Alla on 3/29/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//
//

import Foundation
import CoreData

extension Deal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Deal> {
        return NSFetchRequest<Deal>(entityName: "Deal")
    }

    @NSManaged public var currencyPair: String?
    @NSManaged public var priceClose: Double
    @NSManaged public var priceOpen: Double
    @NSManaged public var profit: Int32
    @NSManaged public var timeClose: NSDate?
    @NSManaged public var timeOpen: NSDate?
    @NSManaged public var type: String?

}
