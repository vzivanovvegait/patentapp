//
//  MenuButton.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/11/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

class MenuButton: UIButton {

    let shapeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    override func draw(_ rect: CGRect) {
        let ellipsePath = UIBezierPath(ovalIn: self.bounds)
        
        shapeLayer.path = ellipsePath.cgPath
        shapeLayer.fillColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
//        shapeLayer.strokeColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
//        shapeLayer.lineWidth = 2.0
//        self.layer.addSublayer(shapeLayer)
        self.layer.insertSublayer(shapeLayer, at: 0)
    }
    
    func setupView() {
        self.backgroundColor? = UIColor.clear
        self.setTitleColor(UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1), for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 25)
    }

}
