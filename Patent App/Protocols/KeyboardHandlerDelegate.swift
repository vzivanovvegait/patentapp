//
//  KeyboardHandlerProtocol.swift
//  TextFieldEdit
//
//  Created by Qidenus on 12/8/17.
//  Copyright © 2017 Vladimir Zivanov. All rights reserved.
//

import Foundation
import UIKit

protocol KeyboardHandlerDelegate {
    
    var scrollView: UIScrollView! { get set}
}

extension KeyboardHandlerDelegate where Self: UIViewController {
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
        var tabBarHeight:CGFloat = 0
        if let tabBarController = self.tabBarController, !tabBarController.tabBar.isHidden {
            tabBarHeight = tabBarController.tabBar.frame.size.height
        }
        
        let contentInsets: UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height - bottomSafeAreaInsets - tabBarHeight, 0.0);
        self.scrollView.contentInset = contentInsets;
        self.scrollView.scrollIndicatorInsets = contentInsets;
        
        if let firstResponderView = findFirstResponder(view: self.view) {
            var visibleRect = self.scrollView.bounds
            visibleRect.size.height -= kbSize.height;
            visibleRect.size.height += bottomSafeAreaInsets
            visibleRect.size.height += tabBarHeight

            var rect = firstResponderView.convert(firstResponderView.bounds, to: scrollView)
            let bottomInputViewPoint = CGPoint(x: 0, y: rect.maxY + 20)

            if !visibleRect.contains(bottomInputViewPoint) {
                rect.size.height += 35
                UIView.animate(withDuration: 0.25, animations: {
                    self.scrollView.scrollRectToVisible(rect, animated: false)
                })
                
            }

        }

    }
    
    fileprivate func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 0.5) {
            let contentInsets = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInsets
            self.scrollView.scrollIndicatorInsets = contentInsets
        }
    }
    
    fileprivate func findFirstResponder(view: UIView) -> UIView? {
        for view in view.subviews {
            if view.isFirstResponder {
                return view
            }
            if let childView = findFirstResponder(view: view){
                return childView
            }
        }
        return nil
    }
    
}


