//
//  Point+CoreDataProperties.swift
//  ForexGame
//
//  Created by Alla on 3/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//
//

import Foundation
import CoreData

extension Point {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Point> {
        return NSFetchRequest<Point>(entityName: "Point")
    }

    @NSManaged public var pointTime: NSDate?
    @NSManaged public var pointPrice: Double

}
