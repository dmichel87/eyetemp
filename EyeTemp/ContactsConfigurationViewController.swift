//
//  ContactsConfigurationViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/29/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContactsConfigurationViewController: UIViewController {
    
    @IBOutlet weak var contactName: DesignableTextField!
    @IBOutlet weak var contactEmail: DesignableTextField!
    @IBOutlet weak var contactNumber: DesignableTextField!
    @IBOutlet weak var contactSave: DesignableButton!

    var disposableBag:DisposeBag = DisposeBag()
    var contact:Contacts! {
        didSet {
            self.varName.value = contact.contact_name!
            self.varEmail.value = contact.email!
            self.varPhone.value = contact.phone!
        }
    }
    var contactUpdated:Variable<Bool> = Variable<Bool>(false)
    var varName:Variable<String> = Variable<String>("")
    var varEmail:Variable<String> = Variable<String>("")
    var varPhone:Variable<String> = Variable<String>("")
    
    let disabledColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let enabledColor  = UIColor(red:0.22, green:0.29, blue:0.41, alpha:1.00)


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.varName.asObservable().bind(to: self.contactName.rx.text)
        .disposed(by: self.disposableBag)
        
        self.varEmail.asObservable().bind(to: self.contactEmail.rx.text)
        .disposed(by: self.disposableBag)
        
        self.varPhone.asObservable().bind(to: self.contactNumber.rx.text)
        .disposed(by: self.disposableBag)
        
        let nameValid:Observable<Bool> = self.contactName.rx.text.map { text in
            guard let t = text else {return false}
            return t.length > 0
            }
            .share(replay:1)
        
        let phoneValid:Observable<Bool> = self.contactNumber.rx.text.map {text in
            guard let t = text else {return false}
            return t.length >= 10
            }
            .share(replay: 1)
        
        let emailValid:Observable<Bool> = self.contactEmail.rx.text.map {text in
            guard let t = text else {return false}
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let result = emailTest.evaluate(with: t)
            return result
            }
            .share(replay: 1)
        
        
        
        //if everything is valid then enable the button
        let everythingValid:Observable<Bool> = Observable.combineLatest(nameValid,phoneValid,emailValid) {$0 && $1 && $2}
        
        everythingValid.bind(to: self.contactSave.rx.isEnabled)
            .disposed(by: self.disposableBag)
        
        //If everything is valid then make the button black color
        everythingValid.subscribe(onNext: { (enabled) in
            //Logger.log(message: "Enabled ?\(enabled)", event: .i)
            if enabled {
                self.contactSave.backgroundColor = self.enabledColor
            }
            else {
                self.contactSave.backgroundColor = self.disabledColor
            }
        })
            .disposed(by: self.disposableBag)
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
        self.contactSave.rx.tap
            .subscribe(onNext: { _ in
                
                //We will read the current device name entered in the text field.
                guard let name = self.contactName.text else {
                    return
                }
                guard let number = self.contactNumber.text else {
                    return
                }
                guard let email = self.contactEmail.text else {
                    return
                }
                self.contact.contact_name = name
                self.contact.phone = number
                self.contact.email = email
                Database.updateContact(contact: self.contact, context: Database.context)
                self.contactUpdated.value = true
                self.dismiss(animated: true, completion: nil)
                
            })
            .disposed(by: self.disposableBag)
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
