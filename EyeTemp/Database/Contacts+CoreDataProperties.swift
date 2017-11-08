//
//  Contacts+CoreDataProperties.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/17/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts")
    }

    @NSManaged public var contact_name: String?
    @NSManaged public var phone: String?
    @NSManaged public var email: String?

}
