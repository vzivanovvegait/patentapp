//
//  SettingsViewConroller.swift
//  e-Homegreen

import UIKit
import CoreData

protocol SettingsDelegate: class {
    func changeFont(fontSize: CGFloat)
}

class SettingsViewConroller: UIViewController {
    
    weak var delegate:SettingsDelegate?
    
    @IBOutlet weak var fontSizeLabel: UILabel!
    @IBOutlet weak var fontSlider: UISlider!
    @IBOutlet weak var backView: UIView!
    
    lazy var shadowView:UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        return view
    }()
    
    var isPresenting: Bool = true
    
    init() {
        super.init(nibName: "SettingsViewConroller", bundle: nil)
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(SettingsViewConroller.dismissViewController))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
        
        let fontSize = UserDefaults.standard.integer(forKey: "fontSize")
        fontSlider.value = Float((fontSize > 25) ? fontSize : 25)
        fontSizeLabel.text = "Font size: \((fontSize > 25) ? fontSize : 25)"
        // Do any additional setup after loading the view.
    }
    
    @objc func dismissViewController () {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func changeFont(_ sender: UISlider) {
        delegate?.changeFont(fontSize: CGFloat(roundf(sender.value)))
        fontSizeLabel.text = "Font size: \(CGFloat(roundf(sender.value)))"
    }
}

extension SettingsViewConroller: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view!.isDescendant(of: backView){
            return false
        }
        return true
    }
}

extension SettingsViewConroller : UIViewControllerAnimatedTransitioning {
    
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
            //presentedControllerView.alpha = 0
            //presentedControllerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            
            containerView.addSubview(shadowView)
            shadowView.alpha = 0
            containerView.addSubview(presentedControllerView)
            
            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                self.shadowView.alpha = 1
                
                presentedControllerView.frame.origin.y = 0
                
//                presentedControllerView.alpha = 1
//                presentedControllerView.transform = CGAffineTransform(scaleX: 1, y: 1)
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }else{
            let presentedControllerView = transitionContext.view(forKey: UITransitionContextViewKey.from)!

            UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
//                presentedControllerView.alpha = 0
//                presentedControllerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                
                presentedControllerView.frame.origin.y = self.view.bounds.height
                
                self.shadowView.alpha = 0
                
                }, completion: {(completed: Bool) -> Void in
                    transitionContext.completeTransition(completed)
            })
        }
        
    }
}

extension SettingsViewConroller : UIViewControllerTransitioningDelegate {
    
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
extension UIViewController {
    func showTimerParametar() -> SettingsViewConroller {
        let vc = SettingsViewConroller()
        self.present(vc, animated: true, completion: nil)
        return vc
    }
}
