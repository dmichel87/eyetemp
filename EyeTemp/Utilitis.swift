//
//  Utilitis.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/17/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit

class Utilitis: NSObject {
    
    static func stringWithUUID() -> String {
        let uuidObj = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuidObj)!
        return uuidString as String
    }
}
