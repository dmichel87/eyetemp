//
//  ItemsListViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 12/25/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ItemsListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var alerts:[Alert] = [Alert]()
    var selectedAlert:Alert?
    var hasChosen:Variable<Bool> = Variable<Bool>(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let alerts = Database.getAlertConfig() {
            self.alerts = alerts
        }
        print(alerts)

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


extension ItemsListViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.alerts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "displayCell") as UITableViewCell!
        let alt = self.alerts[indexPath.row]
        let name = cell?.viewWithTag(121) as! UILabel
        name.text = alt.appliance
        let time = cell?.viewWithTag(123) as! UILabel
        time.text = alt.alertTime
        let placement = cell?.viewWithTag(125) as! UILabel
        placement.text = alt.placement
        //name.text = "\(ch.sitename!):\(ch.name!)"
        return cell!
    }
    
    //    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    //        if editingStyle == .delete {
    //            let appliance = self.items[indexPath.row]
    //            self.sites.remove(at: indexPath.row)
    //            Database.deleteAppliance(name:appliance.appliance_name!, context: Database.context)
    //            self.tableView.deleteRows(at: [indexPath], with: .fade)
    //        }
    //
    //    }
    //
    
    
}

extension ItemsListViewController : UITableViewDelegate {
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedAlert = self.alerts[indexPath.row]
        self.hasChosen.value = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
}
