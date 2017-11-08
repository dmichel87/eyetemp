//
//  ContactAddViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/7/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ContactAddViewController: UIViewController {

    @IBOutlet weak var addButton: DesignableButton!
    @IBOutlet weak var emailTextField: DesignableTextField!
    @IBOutlet weak var phoneTextField: DesignableTextField!
    @IBOutlet weak var nameTextField: DesignableTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var floatingView: DesignableView!
    
    let disabledColor = UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
    let enabledColor  = UIColor(red:0.22, green:0.29, blue:0.41, alpha:1.00)

    var originalOffset:CGPoint!
    var disposeBag = DisposeBag()
    var saved:Variable<Bool> = Variable<Bool>(false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.floatingView.bindToKeyBoard()
        self.originalOffset = self.scrollView.contentOffset
        RxKeyboard.instance.visibleHeight
            .drive(onNext: { keyBoardVisibleHeight in
                if keyBoardVisibleHeight > 0.0 {
                    self.scrollView.contentOffset.y += keyBoardVisibleHeight
                }
                else {
                    self.scrollView.contentOffset = self.originalOffset
                }
                
            })
            .disposed(by: self.disposeBag)
        
        
        let nameValid:Observable<Bool> = self.nameTextField.rx.text.map { text in
            guard let t = text else {return false}
            return t.length > 0
            }
            .share(replay:1)
        
        let phoneValid:Observable<Bool> = self.phoneTextField.rx.text.map {text in
            guard let t = text else {return false}
            return t.length >= 10
            }
            .share(replay: 1)
        
        let emailValid:Observable<Bool> = self.emailTextField.rx.text.map {text in
            guard let t = text else {return false}
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            let result = emailTest.evaluate(with: t)
            return result
            }
            .share(replay: 1)
        
        
        
        //if everything is valid then enable the button
        let everythingValid:Observable<Bool> = Observable.combineLatest(nameValid,phoneValid,emailValid) {$0 && $1 && $2}
        
        everythingValid.bind(to: self.addButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        //If everything is valid then make the button black color
        everythingValid.subscribe(onNext: { (enabled) in
            //Logger.log(message: "Enabled ?\(enabled)", event: .i)
            if enabled {
                self.addButton.backgroundColor = self.enabledColor
            }
            else {
                self.addButton.backgroundColor = self.disabledColor
            }
        })
            .disposed(by: self.disposeBag)
        
        
        
        
        
        
        
        // Do any additional setup after loading the view.
        self.addButton.rx.tap
            .subscribe(onNext: { _ in
                let contact = Contacts(context: Database.context)
                
                //We will read the current device name entered in the text field.
                guard let name = self.nameTextField.text else {
                    return
                }
                guard let number = self.phoneTextField.text else {
                    return
                }
                guard let email = self.emailTextField.text else {
                    return
                }
                contact.contact_name = name
                contact.phone = number
                contact.email = email
                
                Database.saveContext()
                self.saved.value = true
                self.dismiss(animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.view.unbindFromKeyboard()
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
