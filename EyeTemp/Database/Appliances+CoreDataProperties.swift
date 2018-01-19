//
//  Appliances+CoreDataProperties.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/17/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit


extension Appliances {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Appliances> {
        return NSFetchRequest<Appliances>(entityName: "Appliances")
    }

    @NSManaged public var appliance_id: Int16
    @NSManaged public var alert_time: String?
    @NSManaged public var appliance_name: String?
    @NSManaged public var mapped_device: String?
    @NSManaged public var is_monitoring:Bool
    @NSManaged public var mapped_device_id:String?

}
