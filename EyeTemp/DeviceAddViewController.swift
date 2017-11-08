//
//  DeviceAddViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/7/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IHKeyboardAvoiding

class DeviceAddViewController: UIViewController {

    @IBOutlet weak var deviceIdTextField: DesignableTextField!
    @IBOutlet weak var deviceNameTextField: DesignableTextField!
    var deviceSaved:Variable<Bool> = Variable<Bool>(false)
    var disposeBag = DisposeBag()
    @IBOutlet weak var addButton: DesignableButton!
    var originalOffset:CGPoint!
    
    let disabledColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let enabledColor  = UIColor(red:0.22, green:0.29, blue:0.41, alpha:1.00)

    
    @IBOutlet weak var floatingView: DesignableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.floatingView.bindToKeyBoard()
        //When keyboard is shown move the floating view up
       
        KeyboardAvoiding.avoidingView = self.floatingView
        
        
        let deviceIdValid:Observable<Bool> = self.deviceIdTextField.rx.text.map { text in
            guard let t = text else {return false}
            return t.length == 12
            }
            .share(replay: 1)
        
        let deviceNameValid:Observable<Bool> = self.deviceNameTextField.rx.text.map {text in
            guard let t = text else {return false}
            return t.length > 0
        }
        
        let everythingValid:Observable<Bool> = Observable.combineLatest(deviceIdValid,deviceNameValid) {$0 && $1 }
        
        everythingValid.bind(to: self.addButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        //If everything is valid then make the button black color
        everythingValid.subscribe(onNext: { (enabled) in
            //Logger.log(message: "Enabled ?\(enabled)", event: .i)
            if enabled {
                self.addButton.backgroundColor = self.enabledColor
            }
            else {
                self.addButton.backgroundColor = self.disabledColor
            }
        })
            .disposed(by: self.disposeBag)
        
        // Do any additional setup after loading the view.
        self.addButton.rx.tap
        .subscribe(onNext: { _ in
            let device = Devices(context: Database.context)
            device.device_id = self.deviceIdTextField.text!
            device.device_name = self.deviceNameTextField.text!
            self.deviceSaved.value = true
            Database.saveContext()
            
            self.dismiss(animated: true, completion: nil)
            
        })
        .disposed(by: self.disposeBag)
        
        
        
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
