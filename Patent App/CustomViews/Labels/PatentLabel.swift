//
//  PatentLabel.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/1/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class PatentLabel: TTTAttributedLabel {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    // MARK: - Setup
    
    fileprivate func setupViews() {
        self.linkAttributes = [NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)]
        self.activeLinkAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
        self.lineBreakMode = .byWordWrapping
        self.numberOfLines = 0
        self.isUserInteractionEnabled = true
    }

}
