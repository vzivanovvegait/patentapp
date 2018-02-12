//
//  KeyboardHandlerProtocol.swift
//  TextFieldEdit
//
//  Created by Vladimir Zivanov on 12/8/17.
//  Copyright © 2017 Vladimir Zivanov. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardHandlerProtocol {
    
    var sendboxBottomConstraint: NSLayoutConstraint! { get set }
    var containerViewBottomConstraint: NSLayoutConstraint! { get set }
    
}

extension KeyboardHandlerProtocol where Self: UIViewController {
    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillShow, object: nil, queue: nil) { notification in
            self.keyboardWillShow(notification)
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIKeyboardWillHide, object: nil, queue: nil) { notification in
            self.keyboardWillHide(notification)
        }
    }
    
    func deregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    fileprivate func keyboardWillShow(_ notification: Notification) {
        
        let kbSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        var bottomSafeAreaInsets:CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomSafeAreaInsets = self.view.safeAreaInsets.bottom
        }
        
        sendboxBottomConstraint.constant = kbSize.height
        containerViewBottomConstraint.constant = kbSize.height + 50 - bottomSafeAreaInsets
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func keyboardWillHide(_ notification: Notification) {
        self.sendboxBottomConstraint.constant = -50
        containerViewBottomConstraint.constant = 80
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
}

