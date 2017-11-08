//
//  Extensions.swift
//  EyeTemp
//
//  Created by Ranjith Antony on 10/6/17.
//  Copyright © 2017 Perleybrook Labs LLC. All rights reserved.
//

import UIKit

extension UIView {
    func bindToKeyBoard()  {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: NSNotification.Name.UIKeyboardDidChangeFrame, object: nil)
    }
    
    func unbindFromKeyboard(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    
    @objc
    func keyboardWillChange(notification:NSNotification)  {
        guard notification.userInfo != nil else {
            return
        }
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! UInt
        let curFrame = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let targetFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = targetFrame.origin.y - curFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIViewKeyframeAnimationOptions(rawValue:curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
        
    }
}
