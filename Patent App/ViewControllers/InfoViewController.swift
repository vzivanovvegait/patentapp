//
//  InfoViewController.swift
//  Patent App
//
//  Created by Vladimir Zivanov on 2/14/18.
//  Copyright © 2018 Vladimir Zivanov. All rights reserved.
//

import UIKit

final class InfoViewController: UIViewController {
    
    var pageController = UIPageViewController()
    
    var infoParts = [#imageLiteral(resourceName: "wizard_1"), #imageLiteral(resourceName: "wizard_2"), #imageLiteral(resourceName: "wizard_3"), #imageLiteral(resourceName: "wizard_4")]
    var viewControllers = [InfoPartViewController]()
    
    @IBOutlet weak var infoPartContainerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var storyIndex = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setPageControl()
        
        for (index, part) in infoParts.enumerated() {
            let vc:InfoPartViewController = InfoPartViewController.makeFromStoryboard()
            vc.image = part
            vc.index = index
            viewControllers.append(vc)
        }
        
        pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageController.dataSource = self
        pageController.delegate = self
        pageController.setViewControllers([viewControllers.first!], direction: .forward, animated: true, completion: nil)
        
        self.addChildViewController(pageController)
        pageController.view.frame = infoPartContainerView.bounds
        infoPartContainerView.addSubview(pageController.view)
        pageController.didMove(toParentViewController: self)

    }
    
    func setPageControl(){
        pageControl.numberOfPages = infoParts.count
    }

    @IBAction func close(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension InfoViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.index(of: viewController as! InfoPartViewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllers.count > previousIndex else {
            return nil
        }
        return viewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewControllers.index(of: viewController as! InfoPartViewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return viewControllers[nextIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed else { return }
        
        guard let index = (pageViewController.viewControllers?.first as? InfoPartViewController)?.index else { return }
        pageControl.currentPage = index
        print(index)
    }
    
}

extension InfoViewController: StoryboardInitializable {
    
}
