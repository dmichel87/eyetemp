//
//  ViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 9/12/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    
    var timer = Observable<NSInteger>.interval(2.0, scheduler: MainScheduler.instance)
    var disposeBag:DisposeBag!


    override func viewDidLoad() {
        super.viewDidLoad()
        self.disposeBag = DisposeBag()
        // Do any additional setup after loading the view, typically from a nib.
        self.timer
            .subscribe(onNext: { (msecs) in
                let defaults = UserDefaults.standard
                let notified = defaults.bool(forKey: "NOTIFICATION")
                if notified {
                    self.performSegue(withIdentifier: "toHomeViewController", sender: self)
                }
                else {
                    self.performSegue(withIdentifier: "toOnBoarding", sender: self)
                }
        })
        .disposed(by: self.disposeBag)

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toOnBoarding" {
            self.disposeBag = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

