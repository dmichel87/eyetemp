//
//  AlertViewController.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 11/13/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit
import MKRingProgressView


class AlertViewController: UIViewController {

    @IBOutlet weak var tempDisplay: UILabel!
    @IBOutlet weak var voltageDisplay: UILabel!
    @IBOutlet weak var tempProgressView: MKRingProgressView!
    
    @IBOutlet weak var voltageProgressView: MKRingProgressView!
    @IBOutlet weak var alertTime: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
