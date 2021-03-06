//
//  SendContainerView.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 1/18/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

typealias SendViewHandler = (_ text: String) -> ()

class SendContainerView: UIView {
    
    fileprivate var completionHandler: SendViewHandler!

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    // MARK: - Init
    
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
        let nib = UINib(nibName: "SendContainerView", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    fileprivate func setupViews() {
        self.backgroundColor = .white
        textField.returnKeyType = UIReturnKeyType.go
        textField.delegate = self
    }
    
    func registerView(completionHandler: @escaping SendViewHandler) {
        self.completionHandler = completionHandler
    }
    
    func setFirstResponder() {
        textField.becomeFirstResponder()
    }
    
    func removeFirstResponder() {
        textField.resignFirstResponder()
    }
    
    @IBAction func send(_ sender: Any) {
        textField.text = ""
        textField.resignFirstResponder()
    }

}

extension SendContainerView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            completionHandler(text)
        }
        textField.text = ""
        return true
    }
}
