//
//  DevicesViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/27/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DevicesViewController: UIViewController {
    
    @IBOutlet weak var blankView: DesignableLabel!
    @IBOutlet weak var tableView: UITableView!
    var devices:[Devices] = [Devices]()
    var deviceAddViewController:DeviceAddViewController!
    var deviceConfigViewController:DeviceConfigurationViewController!
    var disposeBag = DisposeBag()
    var selectedRow:IndexPath!
    var chooseOnly:Variable<Bool> = Variable<Bool>(false)
    var hasChosen:Variable<Bool> = Variable<Bool>(false)
    var selectedDevice:Devices!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.devices = Database.fetchRecordsForEntity(entity: "Devices", context: Database.context) as! [Devices]
        
        self.tableView.isHidden = self.devices.count == 0 ? true : false
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "deviceAdd" {
            self.deviceAddViewController = segue.destination as! DeviceAddViewController
            self.deviceAddViewController.deviceSaved.asObservable()
            .subscribe(onNext: { saved in
                    if saved {
                        self.devices = Database.fetchRecordsForEntity(entity: "Devices", context: Database.context) as! [Devices]
                        self.tableView.isHidden = self.devices.count == 0 ? true : false
                        self.tableView.reloadData()

                    }
                
            })
            .disposed(by: self.disposeBag)
            
        }
        else if segue.identifier == "toDeviceConfiguration" {
            self.deviceConfigViewController = segue.destination as! DeviceConfigurationViewController
            let device:Devices = self.devices[self.selectedRow.row]
            self.deviceConfigViewController.device = device
            self.deviceConfigViewController.deviceUpdated.asObservable()
                .subscribe(onNext: { saved in
                    if saved {
                        self.devices = Database.fetchRecordsForEntity(entity: "Devices", context: Database.context) as! [Devices]
                        self.tableView.isHidden = self.devices.count == 0 ? true : false
                        self.tableView.reloadData()
                    }
                })
                .disposed(by: self.disposeBag)
            
        }
    }

}

extension DevicesViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.devices.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "displayCell") as UITableViewCell!
        cell.textLabel?.text = self.devices[indexPath.row].device_name
        cell.detailTextLabel?.text = self.devices[indexPath.row].device_id
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let device = self.devices[indexPath.row]
            self.devices.remove(at: indexPath.row)
            Database.deleteDevice(deviceId: device.device_id!, context: Database.context)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    
    
}

extension DevicesViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath
        if !chooseOnly.value {
            self.performSegue(withIdentifier: "toDeviceConfiguration", sender: self)
        }
        else {
            //There are times we need the device to be chosen only. 
            self.selectedDevice = self.devices[indexPath.row]
            self.chooseOnly.value = false
            self.hasChosen.value = true
            self.dismiss(animated: true, completion: nil)
        }
    }
}


