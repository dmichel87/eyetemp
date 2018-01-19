//
//  Alert.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 12/25/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import Gloss

class Alert: JSONDecodable {
    
    let appliance:String?
    let alertTime:String?
    let note:String?
    let placement:String?
    
    required init?(json: JSON) {
        self.appliance = "Appliance" <~~ json
        self.alertTime = "Alert time" <~~ json
        self.note = "Note" <~~ json
        self.placement = "Placement" <~~ json
    }
    

}
