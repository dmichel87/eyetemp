//
//  HomeViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/18/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Gloss

class HomeViewController: UIViewController {

    var items:[Appliances] = [Appliances]()
    @IBOutlet weak var tableView: UITableView!
    var selectedRow:IndexPath!
    var disposeBag:DisposeBag = DisposeBag()
    var tableDispose:DisposeBag!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var toastView: DesignableView!
    var showToast:Variable<Bool> = Variable<Bool>(false)
    var selectedSwitch:UISwitch!
    var initializing = true
    var showInfoToast:Variable<Bool> = Variable<Bool>(false)
    @IBOutlet weak var infoToastLabel: UILabel!
    @IBOutlet weak var infoDismiss: UIButton!
    @IBOutlet weak var infoToastView: DesignableView!
    var monitoredAppliance:Variable<[Appliances]> = Variable<[Appliances]>([])
    var timer = Observable<NSInteger>.interval(2.0, scheduler: MainScheduler.instance)

    @IBOutlet weak var logView: UIView!
    @IBOutlet weak var logTextView: UITextView!
    
    var showLogView:Variable<Bool> = Variable<Bool>(false)
    var settingsGetDispose:DisposeBag!
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableDispose = DisposeBag()
        self.settingsGetDispose = DisposeBag()
        self.items = Database.fetchRecordsForEntity(entity: "Appliances", context: Database.context) as! [Appliances]
        self.tableView.isHidden = self.items.count == 0 ? true : false
        
        self.showToast.asObservable()
        .subscribe(onNext: { val in
            Logger.log(message: "Toast value \(val)", event: .i)
            self.toastView.isHidden = !val
            self.infoToastView.isHidden = true
            self.toastView.animation = "fadeIn"
            self.toastView.duration = 1.0
            self.toastView.animate()
        })
        .disposed(by: self.disposeBag)
        
        self.showInfoToast.asObservable()
        .subscribe(onNext: { val in
                DispatchQueue.main.async {
                self.toastView.isHidden = true
                self.infoToastView.isHidden = !val
                self.infoToastView.animation = "fadeIn"
                self.infoToastView.duration = 1.0
                self.infoToastView.animate()
            }
        })
        .disposed(by: self.disposeBag)
        
        self.showLogView.asObservable()
        .subscribe(onNext: { val  in
            DispatchQueue.main.async {
                self.logView.isHidden = !val
                
            }
        })
        .disposed(by: self.disposeBag)
    
        self.infoDismiss.rx.tap
        .subscribe(onNext: { _ in
            self.showInfoToast.value = false
        })
        .disposed(by: self.disposeBag)
        
        self.dismissButton.rx.tap
        .subscribe(onNext: { _ in
            self.showToast.value = false
            if let swit = self.selectedSwitch {
                swit.isOn = false
            }
        })
        .disposed(by: self.disposeBag)
        
        self.monitoredAppliance.asObservable()
        .subscribe(onNext: { item in
            if item.count > 0 {
                let resetSet:Variable<Bool> = Variable<Bool>(false)
                let resetGet:Variable<Bool> = Variable<Bool>(false)
                let resetSuccess:Observable<Bool> = Observable.combineLatest(resetSet.asObservable(), resetGet.asObservable()) {$0 && $1}

                
                let last = item.last!
                let monitor = Monitor(appliance: last)
                let device = monitor.monitoringAppliance.mapped_device_id! + "0"
                monitor.initDweetStates()
                monitor.dweetResponse
                .subscribe(onNext: { dweet in
                    if let resp = dweet.response {
                        Logger.log(message: "\(resp)", event: .d)
                        if dweet.type == DweetStates.r {
                            //We will convert the json string to an object
                            //then we will check if the settings=0,0. We make sure
                            //that the reset operation is succesful.
                            if let jsonStr = self.convertToDictionary(text: resp) {
                                let dr = DweetForJson(json: jsonStr)
                                if let set = dr?.with?.content?.settings {
                                    if set == "0,0" {
                                        resetSet.value = true
                                        DispatchQueue.main.async {
                                            self.showLogView.value = true
                                            self.logTextView.text.append("💬 Going to reset the server \n")
                                        }
                                    }
                                }
                            }
                        }
                        else if dweet.type == DweetStates.rg {
                            if let jsonStr = self.convertToDictionary(text: resp) {
                                let dg = DweetGetLatest(json: jsonStr)
                                if let set = dg?.with?.first?.content?.settings {
                                    if set == "0,0" {
                                        resetGet.value = true
                                        DispatchQueue.main.async {
                                            self.showLogView.value = true
                                            self.logTextView.text.append("💬 Server is resetted succesfully \n")
                                        }

                                    }
                                }
                            }
                        }
                        else if dweet.type == DweetStates.s {
                            if let jsonStr = self.convertToDictionary(text: resp) {
                                let dg = DweetForJson(json: jsonStr)
                                if let set = dg?.with?.content?.settings {
                                    if set == "1,45" {
                                        //resetGet.value = true
                                        
                                        DispatchQueue.main.async {
                                            self.showLogView.value = true
                                            self.logTextView.text.append("💬 App is trying to contact your EyeTemp Device. Press and hold the button on the device for 6-8 seconds \n")
                                        }
                                        
                                    }
                                }
                            }
                        }
                        else if dweet.type == DweetStates.sg {
                            if let jsonStr = self.convertToDictionary(text: resp) {
                                let dg = DweetGetLatest(json: jsonStr)
                                if let set = dg?.with?.first?.content?.settings {
                                    if set.starts(with: "0"){
                                        DispatchQueue.main.async {
                                            self.showLogView.value = true
                                            self.logTextView.text.append("🔥 App is Ready now \n")
                                            self.settingsGetDispose = nil
                                        }
                                        
                                    }
                                }
                            }
                        }

                    }
                })
                .disposed(by: self.disposeBag)
                
                //Reset the states. Send settings=0,0 to dweet server
                monitor.dweetRequest.onNext(Dweet(url: "https://dweet.io/dweet/for/\(device)", params: "settings=0,0", state:DweetStates.r))
                //Make sure if the settings have reached the dweet and the reset was succesful
                monitor.dweetRequest.onNext(Dweet(url: "http://dweet.io/get/latest/dweet/for/\(device)", params: nil, state:DweetStates.rg))
                
                resetSuccess
                .subscribe(onNext: { val in
                    if val {
                        monitor.dweetRequest.onNext(Dweet(url: "https://dweet.io/dweet/for/\(device)", params: "settings=1,45", state:DweetStates.s))
                        
                        self.timer.subscribe(onNext: { (time) in
                            monitor.dweetRequest.onNext(Dweet(url: "http://dweet.io/get/latest/dweet/for/\(device)", params: nil, state:DweetStates.sg))

                        })
                        .disposed(by: self.settingsGetDispose!)

                        
                    }

                })
                .disposed(by: self.disposeBag)
                
                

           
            }
            
        
        })
        .disposed(by: self.disposeBag)
        
        
        
        self.initializing = false
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toItemAdd" {
            let itemController = segue.destination as! ItemAddViewController
            itemController.itemAdded.asObservable()
            .subscribe(onNext: { val in
                if val {
                    self.items = Database.fetchRecordsForEntity(entity: "Appliances", context: Database.context) as! [Appliances]
                    self.tableView.isHidden = self.items.count == 0 ? true : false
                    self.tableDispose = nil
                    self.tableDispose = DisposeBag()
                    self.tableView.reloadData()
                }
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

extension HomeViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "displayCell") as UITableViewCell!
        let itemLabel = cell.viewWithTag(14) as! UILabel
        let deviceLabel = cell.viewWithTag(16) as! UILabel
        let onSwitch:UISwitch = cell.viewWithTag(18) as! UISwitch
        let secret = cell.viewWithTag(8) as! UILabel
        secret.text = "0"
        let appliance = self.items[indexPath.row]
        itemLabel.text = appliance.appliance_name
        deviceLabel.text = appliance.mapped_device
        onSwitch.isOn = appliance.is_monitoring
        if appliance.is_monitoring {
            monitoredAppliance.value.append(appliance)
        }
        
       onSwitch.rx.value
        .subscribe(onNext: { val in
            if secret.text != "0" {
                let appliance = self.items[indexPath.row] as Appliances
                if val {
                    Logger.log(message: "You have enabled monitoring", event: .i)
                    if !Database.isDeviceMonitored(deviceId: appliance.mapped_device_id!, context: Database.context) {
                        Database.monitorDevice(objid: appliance.objectID, deviceId: appliance.mapped_device_id!, flag: true, context: Database.context)
                        self.monitoredAppliance.value.append(appliance)
                        
                    }
                    else {
                        self.showToast.value = true
                        self.selectedSwitch = onSwitch
                    }
                    
                }
                else {
                     Database.monitorDevice(objid: appliance.objectID, deviceId: appliance.mapped_device_id!, flag: false, context: Database.context)
                }
            }
            else {
                secret.text = "1"
            }
 
        })
        .disposed(by: self.tableDispose)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let appliance = self.items[indexPath.row]
            self.items.remove(at: indexPath.row)
            Database.deleteAppliance(name:appliance.appliance_name!, context: Database.context)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    
    
}

extension HomeViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath
        //self.performSegue(withIdentifier: "toDeviceConfiguration", sender: self)
    }
}

