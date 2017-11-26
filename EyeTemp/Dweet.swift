//
//  Dweet.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/2/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit

// Enum for showing the type of Log Types
enum DweetStates: String {
    case r = "reset" // reset
    case rg = "resetget" //get
    case s = "settings" // initialize
    case sg = "settingsget" // info
    case ming = "monitoring"
}

class Dweet: NSObject {
    
    var response:String?
    var error:String?
    var dweetUrl:URLComponents?
    var type:DweetStates?
    var time:NSInteger?
    
    init(url:String, params:String?, state:DweetStates) {
        dweetUrl = URLComponents(string: url)
        if let p = params {
            dweetUrl?.query = p
        }
        type = state
    }

}
