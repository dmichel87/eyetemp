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
import UserNotifications

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
    var bgTimer = Observable<NSInteger>.interval(2.0, scheduler: ConcurrentDispatchQueueScheduler.init(qos: DispatchQoS.background))

    @IBOutlet weak var logView: UIView!
    @IBOutlet weak var logTextView: UITextView!
    
    var showLogView:Variable<Bool> = Variable<Bool>(false)
    var settingsGetDispose:DisposeBag!
    var appReady:Variable<Bool> = Variable<Bool>(false)
    var alertInfo:[String:Any]?
    
    
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
    
    func applicationEnteredForeground(notification: NSNotification) {
        if Database.getAlert() {
            self.performSegue(withIdentifier: "toAlertVC", sender: self)
        }
    }
    
    func appPostedPushNotification(notification:NSNotification) {
        
        if let obj = notification.object as? [String:Any] {
            Logger.log(message: "Recieved push \(obj)", event: .d)
            let t_message = obj["t_message"]
            let v_message = obj["v_message"]
            self.alertInfo = obj
            Logger.log(message: "t_message = \(t_message) v_message = \(v_message)", event: .i)
            self.performSegue(withIdentifier: "toAlertVC", sender: self)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(appPostedPushNotification), name: NSNotification.Name(rawValue: "com.hubspire.EyeTemp.push"), object: nil)
        


        //NotificationCenter.default.addObserver(self, selector: #selector(applicationEnteredForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.tableDispose = DisposeBag()
        self.settingsGetDispose = DisposeBag()
        self.items = Database.fetchRecordsForEntity(entity: "Appliances", context: Database.context) as! [Appliances]
        self.tableView.isHidden = self.items.count == 0 ? true : false
        let defaults = UserDefaults.standard
        let notified = defaults.bool(forKey: "NOTIFICATION")
        if notified {
            self.performSegue(withIdentifier: "toNotifications", sender: self)
        }
        
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
                monitor.monitoringAppliance.activity?.startAnimating()
                monitor.monitoringAppliance.message?.isHidden = false
                monitor.monitoringAppliance.message?.text = "Your device is being setup .."
                let device = monitor.monitoringAppliance.mapped_device_id! + "0"
                let deviceOnly = monitor.monitoringAppliance.mapped_device_id!
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
                                            monitor.monitoringAppliance.message?.text = "💬 App is trying to contact your Eyetemp Device"
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
                                            monitor.monitoringAppliance.message?.text = "💬 App has established connection with the cloud"
                                        }

                                    }
                                }
                            }
                        }
                        else if dweet.type == DweetStates.s {
                            if let jsonStr = self.convertToDictionary(text: resp) {
                                let dg = DweetForJson(json: jsonStr)
                                if let set = dg?.with?.content?.settings {
                                    let check = "1,\(monitor.monitoringAppliance.alert_time!)"
                                    if set == check {
                                        //resetGet.value = true
                                        
                                        DispatchQueue.main.async {
                                            monitor.monitoringAppliance.message?.text = "💬 Press and hold the device's button for 6-8 seconds"

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
                                            monitor.monitoringAppliance.activity?.stopAnimating()
                                            monitor.monitoringAppliance.message?.isHidden = true
                                            monitor.isAppReady = true
                                            self.settingsGetDispose = nil
                                            self.showInfoToast.value = true
                                            monitor.monitorTempChanges()
                                            self.appReady.value = true
                                            self.infoToastLabel.text = "🔥 App is Ready now"
                                            
                                            
                                        }
                                        
                                    }
                                }
                            }
                        }
                        else if dweet.type == DweetStates.ming {
                            if let jsonStr = self.convertToDictionary(text: resp) {
                                let dg = DweetGetLatest(json: jsonStr)
                                if let temp = dg?.with?.first?.content?.t_alert {
                                    if temp == 1 {
                                        let str = "🏃Device is unattended"
                                        
                                        self.notifyUser(text: str)
                                        
                                    }
                                    else if temp == 2 {
                                        //🚒 Drastic temperature increase (may indicate fire)
                                        let str = "🚒 Drastic temperature increase (may indicate fire)"
                                        self.notifyUser(text: str)

                                    }
                                    else if temp == 3 {
                                        //🌡️ Danger temperatrure reached. Remove Eyetemp from surface (too hot)
                                        let str = "🌡️ Danger temperatrure reached. Remove Eyetemp from surface (too hot)"
                                        self.notifyUser(text: str)

                                    }
                                }
                                if let voltage = dg?.with?.first?.content?.v_alert {
                                    if voltage == 1 {
                                        let str = "🔋 Battery is too low. Charge Eyetemp device"
                                        self.notifyUser(text: str)
                                    }
                                    
                                }
                                if let t = dg?.with?.first?.content?.t {
                                    let str = "♨️ Temperature is now \(t)"
                                    self.notifyUser(text: str)

                                    DispatchQueue.main.async {
                                        self.showInfoToast.value = true
                                        self.infoToastLabel.text = str

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
                monitor.dweetRequest.onNext(Dweet(url: "http://dweet.io/get/latest/dweet/for/\(device)", params: nil, state: DweetStates.rg))
                
                resetSuccess
                .subscribe(onNext: { val in
                    if val {
                        let params = "1,\(monitor.monitoringAppliance.alert_time!)"
                        monitor.dweetRequest.onNext(Dweet(url: "https://dweet.io/dweet/for/\(device)", params: "settings=\(params)", state:DweetStates.s))
                        
                        self.timer.subscribe(onNext: { (time) in
                            let d = Dweet(url: "http://dweet.io/get/latest/dweet/for/\(device)", params: nil, state:monitor.isAppReady ? DweetStates.ming : DweetStates.sg)
                            d.time = time
                            monitor.dweetRequest.onNext(d)


                        })
                        .disposed(by: self.settingsGetDispose!)

                        
                    }

                })
                .disposed(by: self.disposeBag)
                
                /*self.appReady.asObservable()
                .subscribe(onNext: { val in
                    if val {
                        self.bgTimer.subscribe(onNext: { (time) in
                            let d = Dweet(url: "http://dweet.io/get/latest/dweet/for/\(deviceOnly)", params: nil, state: DweetStates.ming )
                            d.time = time
                            monitor.monitorTempDweet.onNext(d)
                            
                            
                        })
                        .disposed(by: self.disposeBag)
                    }
                })
                .disposed(by: self.disposeBag)*/
                
                
                
                
                

           
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
        else if segue.identifier == "toAlertVC" {
            let alertVc = segue.destination as! AlertViewController
            if let alert = self.alertInfo {
                alertVc.t_message = alert["t_message"] as? String
                alertVc.v_message = alert["v_message"] as? String
            }
        }
    }
    

    
    func notifyUser(text:String) {
        //DispatchQueue.main.async {
            if Database.canSaveAlert(text: text, context: Database.context) {
                let content = UNMutableNotificationContent()
                content.title = "EyeTemp"
                content.body = text
                content.sound = UNNotificationSound.default()
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)
                let request = UNNotificationRequest(identifier: Utilitis.stringWithUUID(), content: content, trigger: trigger)
                //UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
                let notification = EyeTempAlerts(context: Database.context)
                notification.alert_time = Date()
                notification.text = text
                Database.saveContext()
            }

        //}
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
        let message = cell.viewWithTag(4) as! UILabel
        let activity = cell.viewWithTag(6) as! UIActivityIndicatorView
        secret.text = "0"
        let appliance = self.items[indexPath.row]
        appliance.activity = activity
        appliance.message = message
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

