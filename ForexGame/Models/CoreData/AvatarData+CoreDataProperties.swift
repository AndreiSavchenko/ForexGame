//
//  AvatarData+CoreDataProperties.swift
//  ForexGame
//
//  Created by Alla on 4/4/19.
//  Copyright © 2019 AndreiSavchenko. All rights reserved.
//
//

import Foundation
import CoreData

extension AvatarData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AvatarData> {
        return NSFetchRequest<AvatarData>(entityName: "AvatarData")
    }

    @NSManaged public var avatarBinaryData: NSData?

}
