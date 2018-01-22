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
    
    var scrollView: UIScrollView! { get set }
    var sendboxBottomConstraint: NSLayoutConstraint! { get set }
    
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
        self.scrollView.isScrollEnabled = true
        
        let kbSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        var bottomSafeAreaInsets:CGFloat = 0
        if #available(iOS 11.0, *) {
            bottomSafeAreaInsets = self.view.safeAreaInsets.bottom
        }
        
        sendboxBottomConstraint.constant = kbSize.height
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - bottomSafeAreaInsets + 50, 0.0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    fileprivate func keyboardWillHide(_ notification: Notification) {
        self.sendboxBottomConstraint.constant = -50
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
            let contentInsets = UIEdgeInsets(top: 60, left: 0, bottom: 80, right: 0)
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
}

extension KeyboardHandlerProtocol where Self: UIViewController {
    func enableDismissKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(Self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
}

private extension UIViewController {
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

