//
//  DialogUtils.swift
//  TextFieldEdit
//
//  Created by Vladimir Zivanov on 12/11/17.
//  Copyright © 2017 Vega IT. All rights reserved.
//

import Foundation
import UIKit

class DialogUtils {
    
    public class func showWarningDialog(_ controller: UIViewController, title: String?, message: String?, completion: (() -> ())?) {
        
        let warningDialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion?()
        })
        
        warningDialog.addAction(action)
        DispatchQueue.main.async {
            controller.present(warningDialog, animated: true, completion: nil)
        }
    }
    
    public class func showYesNoDialog(_ controller: UIViewController, title: String?, message: String?, completion: @escaping (_ selected: Bool) -> ()) {
        
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(true)
        })
        dialog.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "No", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(false)
        })
        dialog.addAction(noAction)
        
        DispatchQueue.main.async {
            controller.present(dialog, animated: true, completion: nil)
            dialog.view.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        }
    }
    
    public static func showMultipleChoiceActionSheet(_ controller: UIViewController, anchor: UIView, title: String?, message: String?, choises: [String], completion: @escaping (_ selected: String) -> ()) {
        
        let optionMenu = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        
        for choise in choises {
            let action = UIAlertAction(title: choise, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                completion(choise)
            })
            optionMenu.addAction(action)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cancelAction)
        if let popoverController = optionMenu.popoverPresentationController {
            popoverController.sourceView = anchor
            popoverController.sourceRect = anchor.bounds
        }
        DispatchQueue.main.async {
            controller.present(optionMenu, animated: true, completion: nil)
            optionMenu.view.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        }
    }
    
    public static func showYesNoDialogWithInput(_ controller: UIViewController, title: String?, message: String?, positive: String, cancel: String?, completion: @escaping (_ selected: Bool, _ text: String?) -> ()) {
        
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let positiveAction = UIAlertAction(title: positive, style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            if let text = (dialog.textFields![0] as UITextField).text {
                completion(true, text)
            }
        })
        
        dialog.addAction(positiveAction)
        
        if let cancelString = cancel {
            let cancelAction = UIAlertAction(title: cancelString, style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                completion(false, nil)
            })
            
            dialog.addAction(cancelAction)
        }
        
        dialog.addTextField { (textField : UITextField!) -> Void in
        }
        
        DispatchQueue.main.async {
            controller.present(dialog, animated: true, completion: nil)
            dialog.view.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        }
        
    }
    
    public class func showSaveDialog(_ controller: UIViewController, title: String?, message: String?, completion: @escaping (_ selected: String) -> ()) {
        
        let dialog = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let customAction = UIAlertAction(title: "Custom text", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion("text")
        })
        dialog.addAction(customAction)
        
        let clueAction = UIAlertAction(title: "Clue", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion("clue")
        })
        dialog.addAction(clueAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            completion("")
        })
        dialog.addAction(cancelAction)
        
        DispatchQueue.main.async {
            controller.present(dialog, animated: true, completion: nil)
            dialog.view.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        }
    }
    
}
