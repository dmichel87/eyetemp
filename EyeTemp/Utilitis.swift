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
    
    static func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
   
}
