//
//  OnboardingPageViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 15/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

// Global optional variable
var gSlide1: OnBoardingViewController?
var gSlide2: OnBoardingViewController?
var gSlide3: OnBoardingViewController?
var gSpots: [Spot]?

/// Important: Before creating object of `OnboardingPageViewController`, always initialize all slide objects and spots array.
class OnboardingPageViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var descriptionContainerView: UIView!
    
    @IBOutlet weak var instructionLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var imgLeftArrow: UIImageView!
    @IBOutlet weak var imgRightArrow: UIImageView!
    
    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    
    let viewControllers: [UIViewController] = [
        gSlide1!,
        gSlide2!,
        gSlide3!,
        NetworkViewController(splashAnim: false, didComeFromOB: true)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        
        addChild(pageViewController)
        containerView.addSubview(pageViewController.view)
        pageViewController.view.constraintToFit(inContainerView: containerView)
        pageViewController.didMove(toParent: self)
        self.pageViewController.setViewControllers([self.viewControllers[0]], direction: .forward, animated: false, completion: nil)
        
        applyStyle()
        toggleHiddenViews()

        // Find and set delegate to scrollview of pageViewController
        let scrollView = pageViewController.view.subviews.filter { $0 is UIScrollView }.first as! UIScrollView
        scrollView.delegate = self
    }
    
    private func applyStyle() {
        if #available(iOS 13.0, *) {
            let statusBar: UIView = UIView(frame: (UIApplication.shared.delegate?.window??.windowScene?.statusBarManager?.statusBarFrame)!)
            statusBar.backgroundColor = .black
            let tag = 778899
            if let taggedView = self.view.viewWithTag(tag) {
                taggedView.removeFromSuperview()
            }
            statusBar.tag = tag
            self.view.addSubview(statusBar)
            self.view.bringSubviewToFront(statusBar)
          } else {
            // Fallback on earlier versions
            UIApplication.shared.statusBarView?.backgroundColor = .black
        }
        if #available(iOS 14.0, *) {
            pageControl.allowsContinuousInteraction = false;
            pageControl.backgroundStyle = .minimal;
        } else {
            // Fallback on earlier versions
        };
        pageControl.currentPage = index
        pageControl.numberOfPages = numberOfPages - 1
        pageControl.transform = CGAffineTransform(scaleX: 2, y: 2)
        
        instructionLabel.font = UIFont.appNormal.withSize(UIFont.sizes.small-2)
        instructionLabel.textColor = UIColor.white
        descriptionContainerView.backgroundColor = UIColor.clear
        descriptionContainerView.isUserInteractionEnabled = false
    }
    
    func toggleHiddenViews() {
        imgLeftArrow.isHidden = index == 0
        instructionLabel.text = L10n.OnboardingPageViewController.swipe
    }
}


extension OnboardingPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController), index > 0 {
            return viewControllers[index - 1]
        }
        
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = viewControllers.firstIndex(of: viewController), index < numberOfPages - 1 {
            return viewControllers[index + 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentViewController = pageViewController.viewControllers?.first as? OnBoardingViewController {
            pageControl.currentPage = currentViewController.index
            toggleHiddenViews()
            return // current controller is slide #1, #2 or #3, so no need to check below condition
        }
        
        if completed, let currentViewController = pageViewController.viewControllers?.first as? NetworkViewController {
            self.view.isUserInteractionEnabled = false
            instructionLabel.isHidden = true
            pageControl.isHidden = true
            imgLeftArrow.isHidden = true
            imgRightArrow.isHidden = true
            
            // resume normal login flow
            currentViewController.apiVersion()
            
            AmplitudeAnalytics.logEvent(.completeTutorial, group: .onBoarding)
        }
    }
    
    var index: Int {
        return pageControl.currentPage
    }
    
    var numberOfPages: Int {
        return viewControllers.count
    }
}

extension OnboardingPageViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Hide "Swipe to start" text when third slide swiped half
        let refOffset: CGFloat = view.frame.width + (view.frame.width * 0.5)
        if index == 2 && scrollView.contentOffset.x >= refOffset {
            descriptionContainerView.isHidden = true
        } else {
            descriptionContainerView.isHidden = false
        }
    }
}
