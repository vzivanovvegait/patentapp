//
//  FinishController.swift
//  Myte
//
//  Created by Code Tribe on 8/12/17.
//  Copyright © 2017 Myte. All rights reserved.
//

import Foundation
import UIKit

class FinishController {
    
    static let shared = FinishController()
    
    fileprivate var finishView: FinishView?
    
    public func showFinishView(completionHandler: FinishViewHandler?) {
        if (finishView == nil) {
            let window = UIApplication.shared.keyWindow!
            
            finishView = FinishView(frame: window.frame, completionHandler: completionHandler)
            window.addSubview(finishView!)
        }
    }
    
    public func hideFinishView() {
        guard let finishView = finishView else {
            return
        }
        
        finishView.removeFromSuperview()
        self.finishView = nil
    }
}
