//
//  Appliances+CoreDataClass.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/17/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//
//

import Foundation
import CoreData
import UIKit

@objc(Appliances)
public class Appliances: NSManagedObject {
    public var message:UILabel?
    public var activity:UIActivityIndicatorView?

}
