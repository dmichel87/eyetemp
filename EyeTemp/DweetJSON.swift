//
//  DweetJSON.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/2/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import Gloss



class DweetContent : Gloss.Decodable {

    var settings:String?

    required init?(json: JSON) {
        self.settings = "settings" <~~ json
    }
    
    
}

class DweetWith : Gloss.Decodable {
    
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

class DweetGetLatest : Gloss.Decodable {
    
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

class DweetForJson : Gloss.Decodable {
    
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
