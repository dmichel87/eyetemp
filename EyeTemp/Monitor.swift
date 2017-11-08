//
//  Monitor.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/30/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import SwiftyJSON

class Monitor : NSObject {
    
    let monitoringAppliance:Appliances!
    var dweetTask:URLSessionDataTask?
    var bufferedDweets:[Dweet]?

   
    var dweetRequest = PublishSubject<Dweet>()
    var dweetResponse = PublishSubject<Dweet>()
    var disposeBag = DisposeBag()
    
    init(appliance:Appliances) {
        
        monitoringAppliance = appliance
        let device = monitoringAppliance.mapped_device_id! + "0"
        /*dweetUrL = "https://dweet.io/dweet/for/\(device)"
        listeningUrL = "https://dweet.io/get/latest/dweet/for/\(device)"
        monitorUrl = "https://dweet.io/dweet/for/\(monitoringAppliance.mapped_device!)"*/
    }
    
    func initDweetStates() {
        var delay = 0.0
        dweetRequest.flatMap { (dweet) -> Observable<Dweet> in
            //We need to fire http requests 2 seconds apart, otherwise dweet server will
            //complain about a rate limit
            delay = delay + 6.0
            return Observable.just(dweet).delaySubscription(RxTimeInterval(delay), scheduler: MainScheduler.instance)
        }
        .subscribe(onNext: { (dweet) in
            Logger.log(message: "Fire \(dweet.dweetUrl!)", event: .s)
            self.dweetIt(dweet: dweet)
        })
        .disposed(by: self.disposeBag)
        
    }
    
    
    
    func dweetIt(dweet:Dweet) {
        
        
        if var urlComponents = dweet.dweetUrl {
            Logger.log(message: "Started monitoring \(urlComponents.string!)", event: .d)
            defer {
                self.dweetTask = nil
            }
            guard let url = urlComponents.url else {return}
            self.dweetTask = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    dweet.error = error.localizedDescription
                    self.dweetResponse.onNext(dweet)
                    
                }
                else if let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    if let responseStr = String(data:data, encoding: .utf8) {
                        dweet.response = responseStr
                        self.dweetResponse.onNext(dweet)
                    }
                }
                else if let data = data {
                    if let error = String(data:data, encoding:.utf8) {
                        dweet.error = error
                        self.dweetResponse.onNext(dweet)
                    }
                }
            }
            self.dweetTask?.resume()
        }
        
    }
}


