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
        
        let yesAction = UIAlertAction(title: "Da", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(true)
        })
        dialog.addAction(yesAction)
        
        let noAction = UIAlertAction(title: "Ne", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            completion(false)
        })
        dialog.addAction(noAction)
        
        DispatchQueue.main.async {
            controller.present(dialog, animated: true, completion: nil)
        }
    }
    
}
