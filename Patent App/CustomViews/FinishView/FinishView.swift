//
//  FinishView.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/17/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

typealias FinishViewHandler = () -> ()

class FinishView: UIView {
    
    fileprivate var completionHandler: FinishViewHandler?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    // MARK: - Init
    
    init(frame: CGRect, completionHandler: FinishViewHandler?) {
        self.completionHandler = completionHandler
        
        super.init(frame: frame)
        
        xibSetup()
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    fileprivate func xibSetup() {
        let nib = UINib(nibName: "FinishView", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        view.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.6)
        
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = .clear
        
        backView.backgroundColor = UIColor(red: 242/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1)
        backView.layer.cornerRadius = 15
        backView.layer.borderColor = UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1).cgColor
        backView.layer.borderWidth = 5
    }
    
    public func set(completion: FinishViewHandler?) {
        self.completionHandler = completion
    }

    @IBAction func next(_ sender: Any) {
        completionHandler?()
    }
}
