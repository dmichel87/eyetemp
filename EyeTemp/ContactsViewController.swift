//
//  ContactsViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/29/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var contacts:[Contacts] = [Contacts]()
    var selectedRow:IndexPath!
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contacts = Database.fetchRecordsForEntity(entity: "Contacts", context: Database.context) as! [Contacts]
        self.tableView.isHidden = self.contacts.count == 0 ? true : false

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toContactAdd" {
            let contactAddCtrler = segue.destination as! ContactAddViewController
            contactAddCtrler.saved
            .asObservable()
            .subscribe(onNext: { val in
                if val {
                    self.contacts = Database.fetchRecordsForEntity(entity: "Contacts", context: Database.context) as! [Contacts]
                    self.tableView.isHidden = self.contacts.count == 0 ? true : false
                    self.tableView.reloadData()
                }
            })
            .disposed(by: self.disposeBag)
            
        }
        else if segue.identifier == "toContactConfig" {
            let configController = segue.destination as! ContactsConfigurationViewController
            let contact = self.contacts[self.selectedRow.row]
            configController.contact = contact
            configController.contactUpdated.asObservable()
                .subscribe(onNext: { val in
                    if val {
                        self.contacts = Database.fetchRecordsForEntity(entity: "Contacts", context: Database.context) as! [Contacts]
                        self.tableView.isHidden = self.contacts.count == 0 ? true : false
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

extension ContactsViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.contacts.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "displayCell") as UITableViewCell!
        let nameLabel = cell.viewWithTag(20) as! UILabel
        let emailLabel = cell.viewWithTag(22) as! UILabel
        let phoneLabel = cell.viewWithTag(24) as! UILabel
        let contact = self.contacts[indexPath.row]
        nameLabel.text = contact.contact_name
        emailLabel.text = contact.email
        phoneLabel.text = contact.phone
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contact = self.contacts[indexPath.row]
            Database.deleteContact(emailId: contact.email!, context: Database.context)
            self.contacts.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.isHidden = self.contacts.count == 0 ? true : false
        }
        
    }
    
    
    
}

extension ContactsViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath
        self.performSegue(withIdentifier: "toContactConfig", sender: self)
    }
}


