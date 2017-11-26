//
//  NotificationsViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/13/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var alerts:[EyeTempAlerts] = [EyeTempAlerts]()
    var selectedRow:IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.alerts = Database.fetchRecordsForEntity(entity: "EyeTempAlerts", context: Database.context) as! [EyeTempAlerts]
        self.tableView.isHidden = self.alerts.count == 0 ? true : false

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

extension NotificationsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alerts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "displayCell") as UITableViewCell!
        cell.textLabel?.text = self.alerts[indexPath.row].text! as String
        let formatter = DateFormatter()
        formatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        cell.detailTextLabel?.text = formatter.string(from: self.alerts[indexPath.row].alert_time! as Date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let alert = self.alerts[indexPath.row]
            self.alerts.remove(at: indexPath.row)
            Database.deleteAlert(date: alert.alert_time!, context: Database.context)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
    }
    
    
    
}

extension NotificationsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath
        /*if !chooseOnly.value {
            self.performSegue(withIdentifier: "toDeviceConfiguration", sender: self)
        }
        else {
            //There are times we need the device to be chosen only.
            self.selectedDevice = self.devices[indexPath.row]
            self.chooseOnly.value = false
            self.hasChosen.value = true
            self.dismiss(animated: true, completion: nil)
        }*/
    }
}

