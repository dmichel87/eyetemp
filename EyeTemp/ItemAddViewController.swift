//
//  ItemAddViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/6/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IHKeyboardAvoiding

class ItemAddViewController: UIViewController {

    @IBOutlet weak var itemNameTextField: DesignableTextField!
    @IBOutlet weak var deviceNameTextField: DesignableTextField!
    @IBOutlet weak var addButton: DesignableButton!
    var itemAdded:Variable<Bool> = Variable<Bool>(false)
    
    @IBOutlet weak var floatingView: DesignableView!
    var disposeBag = DisposeBag()
    var mappedDevice:Devices!
    
    let disabledColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let enabledColor  = UIColor(red:0.22, green:0.29, blue:0.41, alpha:1.00)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        KeyboardAvoiding.avoidingView = self.floatingView
        
   
        
        //Add button
        self.addButton.rx.tap
        .subscribe(onNext: { _ in
            let appliance = Appliances(context: Database.context)
            appliance.appliance_name = self.itemNameTextField.text!
            appliance.mapped_device = self.deviceNameTextField.text!
            appliance.mapped_device_id = self.mappedDevice.device_id!
            appliance.is_monitoring = false
            Database.saveContext()
            self.itemAdded.value = true
            self.dismiss(animated: true, completion: nil)
            
        })
        .disposed(by: self.disposeBag)
    }
    
   

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toDeviceList" {
            let deviceViewControler = segue.destination as! DevicesViewController
            deviceViewControler.chooseOnly.value = true
            deviceViewControler.hasChosen.asObservable()
            .subscribe(onNext: { _ in
                let device = deviceViewControler.selectedDevice
                self.deviceNameTextField.text = device?.device_name
                self.mappedDevice = device
            })
            .disposed(by: self.disposeBag)
            
        }
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
