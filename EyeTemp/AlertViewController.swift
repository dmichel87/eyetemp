//
//  AlertViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/13/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import Foundation
import MKRingProgressView
import RxSwift
import RxCocoa


class AlertViewController: UIViewController {

    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var voltageDisplay: UILabel!
    @IBOutlet weak var tempProgressView: MKRingProgressView!
    
    @IBOutlet weak var voltageProgressView: MKRingProgressView!
    @IBOutlet weak var alertTime: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    var t_message:String?
    var v_message:String?
    @IBOutlet weak var acknowledgeBtn: DesignableButton!
    var disposeBag:DisposeBag?
    
    func displayMessage() {
        if !(t_message?.isEmpty)! {
            if let msg = t_message {
                switch msg {
                case "Device left unattended.":
                    voltageDisplay.text = "🏃‍♂️"
                    break;
                case "Drastic temperature increase.":
                    voltageDisplay.text = "🚒"
                    break;
                case "Danger temperature reached.":
                    voltageDisplay.text = "🌡️"
                    break;
                    
                    //Low battery.
                    
                default:
                    self.messageLabel.text = "Unknown message"
                    
                }
                self.messageLabel.text = msg
            }
            
        }
        else if !(v_message?.isEmpty)! {
            voltageDisplay.text = "🔋"
            self.messageLabel.text = v_message!
        }
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        voltageProgressView.progress = 100.0
        CATransaction.commit()
        
        
        
        

    }
    
    func appPostedPushNotification(notification:NSNotification) {
        
        if let obj = notification.object as? [String:Any] {
            Logger.log(message: "Recieved push \(obj)", event: .d)
            self.t_message = obj["t_message"] as? String
            self.v_message = obj["v_message"] as? String
            Logger.log(message: "t_message = \(t_message) v_message = \(v_message)", event: .i)
            self.displayMessage()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disposeBag = DisposeBag()
       NotificationCenter.default.addObserver(self, selector: #selector(appPostedPushNotification), name: NSNotification.Name(rawValue: "com.hubspire.EyeTemp.push"), object: nil)
      
        // Do any additional setup after loading the view.
        self.displayMessage()
        self.acknowledgeBtn.rx.tap
        .subscribe(onNext: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        .disposed(by: self.disposeBag!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
