//
//  OnboardingAddContactViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/18/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreData
import IHKeyboardAvoiding

class OnboardingAddContactViewController: UIViewController {
    
    @IBOutlet weak var contactName: DesignableTextField!
    @IBOutlet weak var contactEmail: DesignableTextField!
    @IBOutlet weak var contactNumber: DesignableTextField!
    @IBOutlet weak var contactSave: DesignableButton!
    var disposableBag:DisposeBag!
    @IBOutlet weak var floatingView: DesignableView!
    @IBOutlet weak var floatingViewHeight: NSLayoutConstraint!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var bottomHeight: NSLayoutConstraint!
    var originalOffset:CGPoint!
    
    let disabledColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let enabledColor  = UIColor(red:0.22, green:0.29, blue:0.41, alpha:1.00)
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.disposableBag = DisposeBag()
        self.contactSave.backgroundColor = self.disabledColor
        KeyboardAvoiding.avoidingView = self.floatingView
        
        
        //When keyboard is shown move the floating view up
        /*RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyBoardVisibleHeight in
                if keyBoardVisibleHeight > 0.0 {
                    self.scrollView.contentOffset.y += keyBoardVisibleHeight
                }
                else {
                    self.scrollView.contentOffset = self.originalOffset
                }
                
            })
            .disposed(by: self.disposableBag)*/
        
        

        //When you tap on the back button dismiss the keyword
        self.backButton.rx.tap
            .subscribe(onNext:{_ in
                self.contactName.resignFirstResponder()
                self.contactEmail.resignFirstResponder()
                self.contactNumber.resignFirstResponder()
                
            })
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
                let contact = Contacts(context: Database.context)

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
                contact.contact_name = name
                contact.phone = number
                contact.email = email

                Database.saveContext()
                self.performSegue(withIdentifier: "toHomeScreen", sender: self)
            })
            .disposed(by: self.disposableBag)

        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.disposableBag = nil
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
