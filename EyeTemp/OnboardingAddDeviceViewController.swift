//
//  OnboardingAddDeviceViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/18/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IHKeyboardAvoiding



class OnboardingAddDeviceViewController: UIViewController {
    
    @IBOutlet weak var saveDeviceBtn: DesignableButton!
    var device:Devices?
    @IBOutlet weak var deviceTxtField: DesignableTextField!
    var disposableBag:DisposeBag!
    @IBOutlet weak var floatingView: DesignableView!
    var floatingViewOrigin:CGPoint!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deviceFriendlyNameTextField: DesignableTextField!
    var originalOffset:CGPoint!
    
    let deviceIdLimit = 12
    let disabledColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let enabledColor  = UIColor(red:0.22, green:0.29, blue:0.41, alpha:1.00)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disposableBag = DisposeBag()
        self.floatingViewOrigin = self.floatingView.frame.origin
        self.saveDeviceBtn.backgroundColor = self.disabledColor
        KeyboardAvoiding.avoidingView = self.floatingView


      
        
        //When you click outside the floating view, the keyboard
        //should disappear
        self.backButton.rx.tap
            .subscribe(onNext: { _ in
                self.deviceTxtField.resignFirstResponder()
            })
        .disposed(by: self.disposableBag)
        
        let deviceIdValid:Observable<Bool> = self.deviceTxtField.rx.text.map { text in
            guard let t = text else {return false}
            return t.length == 12
        }
        .share(replay: 1)
        
        let deviceNameValid:Observable<Bool> = self.deviceFriendlyNameTextField.rx.text.map {text in
            guard let t = text else {return false}
            return t.length > 0
        }
        
        let everythingValid:Observable<Bool> = Observable.combineLatest(deviceIdValid,deviceNameValid) {$0 && $1 }
        
        everythingValid.bind(to: self.saveDeviceBtn.rx.isEnabled)
            .disposed(by: self.disposableBag)
        
        //If everything is valid then make the button black color
        everythingValid.subscribe(onNext: { (enabled) in
            //Logger.log(message: "Enabled ?\(enabled)", event: .i)
            if enabled {
                self.saveDeviceBtn.backgroundColor = self.enabledColor
            }
            else {
                self.saveDeviceBtn.backgroundColor = self.disabledColor
            }
        })
            .disposed(by: self.disposableBag)


        
       

        //When save button is tapped save it here.
        self.saveDeviceBtn.rx.tap
            .subscribe(onNext: { _ in
                let device = Devices(context: Database.context)
            
                //We will read the current device name entered in the text field.
                guard let id = self.deviceTxtField.text else {
                    return
                }
                guard let name = self.deviceFriendlyNameTextField.text else {
                    return
                }
                device.device_id = id
                device.device_name = name
                device.is_mapped = false
                Database.saveContext()
                self.performSegue(withIdentifier: "toOnBoardAddContact", sender: self)
        })
        .disposed(by: self.disposableBag)

        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Logger.log(message: "View Disappeared", event: .i)
        self.disposableBag = nil
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
