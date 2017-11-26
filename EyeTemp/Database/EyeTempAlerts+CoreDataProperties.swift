//
//  EyeTempAlerts+CoreDataProperties.swift
//  
//
//  Created by Ranjith Antony on 11/15/17.
//
//

import Foundation
import CoreData


extension EyeTempAlerts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EyeTempAlerts> {
        return NSFetchRequest<EyeTempAlerts>(entityName: "EyeTempAlerts")
    }

    @NSManaged public var alert_time: Date?
    @NSManaged public var text: String?

}
