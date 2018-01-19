//
//  PushNotifications.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 12/6/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import Foundation
import UIKit

class PushNotifications {
    
    static var Instance = PushNotifications()
    var dataTask:URLSessionDataTask?

    
    private init() {

    }
    
    func postToken(token:String) {
        if var urlComponents = URLComponents(string:"http://dweet.mjzac.com/token") {
            Logger.log(message: "Started monitoring \(urlComponents.string!)", event: .d)
            defer {
                self.dataTask = nil
            }
            guard let url = urlComponents.url else {return}
            var request = URLRequest(url: urlComponents.url!)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            let postString = "token=\(token)"
            request.httpBody = postString.data(using: .utf8)
            
            self.dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
                
                guard let data = data, error == nil else {
                    Logger.log(message: "Unknown error \(error)", event: .s)
                    return
                }
                
                if let httpsStatus = response as? HTTPURLResponse, httpsStatus.statusCode != 200 {
                    Logger.log(message: "Status Code should be 200, but is \(httpsStatus.statusCode)", event: .d)
                    Logger.log(message: "Response \(response)", event: .d)
                }
                let responseString = String(data:data, encoding:.utf8)
                Logger.log(message: "\(responseString)", event: .d)
            }
            self.dataTask?.resume()
        }
    }
    
}
