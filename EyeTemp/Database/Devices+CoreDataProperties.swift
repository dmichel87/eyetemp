//
//  Devices+CoreDataProperties.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/17/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Devices {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Devices> {
        return NSFetchRequest<Devices>(entityName: "Devices")
    }

    @NSManaged public var device_id: String?
    @NSManaged public var device_name: String?
    @NSManaged public var is_mapped: Bool

}
