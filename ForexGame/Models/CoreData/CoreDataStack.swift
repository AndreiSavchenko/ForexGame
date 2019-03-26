//
//  CoreDataStack.swift
//  ForexGame
//
//  Created by Alla on 3/21/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()
    private init() { }

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ModelPoint")
        container.loadPersistentStores(completionHandler: { (persistentStoreDescription, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            debugPrint(persistentStoreDescription)
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        })
        return container
    }()
}
