//
//  LevelViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 3/6/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

protocol LevelDelegate: class {
    func levelChanged(level: Level)
}

enum Level: String {
    case easy = "Without time", medium = "60 seconds", hard = "30 seconds"
}

class LevelViewController: UIViewController {
    
    weak var delegate:LevelDelegate?
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var pickerView: UIPickerView!
    
    let levels = [Level.easy, Level.medium, Level.hard]
    
    var currentLevel:Level!
    
    lazy var shadowView:UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    
    var isPresenting: Bool = true
    
    init() {
        super.init(nibName: "LevelViewController", bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = UIModalPresentationStyle.custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.layer.cornerRadius = 10
        backView.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LevelViewController.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        if currentLevel != nil, let index = levels.index(of: currentLevel) {
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }

        // Do any additional setup after loading the view.
    }
    
    @objc func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func apply(_ sender: Any) {
        delegate?.levelChanged(level: currentLevel)
        self.dismissViewController()
    }
}

extension LevelViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }
}

extension LevelViewController : UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting == true{
            isPresenting = false
            
            let presentedController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.to)!
            let containerView = transitionContext.containerView
            
            presentedControllerView.frame = transitionContext.finalFrame(for: presentedController)
            presentedControllerView.frame.origin.y += self.view.bounds.height
            
            containerView.addSubview(shadowView)
            shadowView.alpha = 0
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                self.shadowView.alpha = 1
                presentedControllerView.frame.origin.y = 0
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                presentedControllerView.frame.origin.y = self.view.bounds.height
                self.shadowView.alpha = 0
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension LevelViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return self
        } else {
            return nil
        }
    }
    
}

extension LevelViewController : UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return levels.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        return NSAttributedString(string: levels[row].rawValue, attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 0, green: 97/255.0, blue: 104/255.0, alpha: 1)])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentLevel = levels[row]
    }
    
}

extension UIViewController {
    func showLevelParametar(level: Level) -> LevelViewController {
        let vc = LevelViewController()
        vc.currentLevel = level
        self.present(vc, animated: true, completion: nil)
        return vc
    }
}
