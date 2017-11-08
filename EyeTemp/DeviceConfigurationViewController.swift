//
//  DeviceConfigurationViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/28/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DeviceConfigurationViewController: UIViewController {
    
    var deviceId:Variable<String> = Variable<String>("")
    var deviceFriendlyName:Variable<String> = Variable<String>("")
    @IBOutlet weak var deviceIdTextField: DesignableTextField!
    @IBOutlet weak var deviceNameTextField: DesignableTextField!
    @IBOutlet weak var saveButton: DesignableButton!
    var deviceUpdated:Variable<Bool> = Variable<Bool>(false)
    var disposeBag = DisposeBag()
    var device:Devices! {
        didSet {
            self.deviceId.value = device.device_id!
            self.deviceFriendlyName.value = device.device_name!
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.deviceId.asObservable()
            .bind(to: self.deviceIdTextField.rx.text)
        .disposed(by: self.disposeBag)
        
        self.deviceFriendlyName.asObservable()
            .bind(to:self.deviceNameTextField.rx.text)
        .disposed(by: self.disposeBag)
        
        self.saveButton.rx.tap
            .subscribe(onNext: { _ in
                self.deviceId.value = self.deviceIdTextField.text!
                self.deviceFriendlyName.value = self.deviceNameTextField.text!
                Database.updateDevice(deviceId: self.deviceId.value, deviceName: self.deviceFriendlyName.value, context: Database.context)
                self.deviceUpdated.value = true
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)

        // Do any additional setup after loading the view.
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
