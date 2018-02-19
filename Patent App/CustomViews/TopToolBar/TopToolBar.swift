//
//  TopToolBar.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/9/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class TopToolBar: UIView {

    var backAction: (()->())?
    var restartAction: (()->())?
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var reloadButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        xibSetup()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        xibSetup()
        setupViews()
    }
    
    // MARK: - Setup
    
    fileprivate func xibSetup() {
        let nib = UINib(nibName: "TopToolBar", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = UIColor.clear
        
//        backButton.setImage(#imageLiteral(resourceName: "back").withRenderingMode(.alwaysTemplate), for: .normal)
//        backButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        reloadButton.setImage(#imageLiteral(resourceName: "restart").withRenderingMode(.alwaysTemplate), for: .normal)
        reloadButton.tintColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)
        
    }
    
    // Actions
    
    @IBAction func back(_ sender: Any) {
        backAction?()
    }
    
    @IBAction func reload(_ sender: Any) {
        restartAction?()
    }

}
