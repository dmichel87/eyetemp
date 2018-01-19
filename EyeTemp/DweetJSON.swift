//
//  DweetJSON.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/2/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import Gloss



class DweetContent : JSONDecodable {

    var settings:String?
    var t_alert:Int?
    var v_alert:Int?
    var t:Double?

    required init?(json: JSON) {
        self.settings = "settings" <~~ json
        self.t_alert = "t_alert" <~~ json
        self.v_alert = "v_alert" <~~ json
        self.t = "t" <~~ json
    }
    
    
}



class DweetWith : JSONDecodable {
    
    var thing:String?
    var created:String?
    var transaction:String?
    var content:DweetContent?
    
    required init?(json: JSON) {
        self.thing = "thing" <~~ json
        self.created = "created" <~~ json
        self.transaction = "transaction" <~~ json
        self.content = "content" <~~ json
        
    }
    
    
}

class DweetGetLatest : JSONDecodable {
    
    var this:String?
    var by:String?
    var the:String?
    var with:[DweetWith]?
    
    required init?(json: JSON) {
        self.this = "this" <~~ json
        self.by   = "by" <~~ json
        self.the  = "the" <~~ json
        self.with = "with" <~~ json
    }
    
    
}

class DweetForJson : JSONDecodable {
    
    var this:String?
    var by:String?
    var the:String?
    var with:DweetWith?
    
    required init?(json: JSON) {
        self.this = "this" <~~ json
        self.by   = "by" <~~ json
        self.the  = "the" <~~ json
        self.with = "with" <~~ json
    }
    
    
}


