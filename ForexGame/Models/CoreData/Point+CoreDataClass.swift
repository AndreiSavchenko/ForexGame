//
//  Point+CoreDataClass.swift
//  ForexGame
//
//  Created by Alla on 3/20/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Point)
public class Point: NSManagedObject {

    class func fetchAll(from context: NSManagedObjectContext = CoreDataStack.shared.persistentContainer.viewContext) -> [Point] {
        let request: NSFetchRequest<Point> = fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "pointTime", ascending: true)]
        let points = try? context.fetch(request)
        return points ?? []
    }
    
}
