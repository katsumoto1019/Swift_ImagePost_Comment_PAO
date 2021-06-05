//
//  PullUpPresentationController.swift
//  Pao
//
//  Created by Parveen Khatkar on 7/18/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class PullUpPresentationController: UIPresentationController {
    
    enum Style {
        case simple
        case borderdCorners(width: CGFloat)
    }
    
    var style: Style = .simple
    var heightPercent: CGFloat = 0.93
    
    private var initialized = false
    
    override var frameOfPresentedViewInContainerView: CGRect {
        initialize()

        let window = UIApplication.shared.keyWindow
        let bottomPadding: CGFloat = window?.safeAreaInsets.bottom ?? 0

        let height = containerView!.bounds.height * heightPercent
        let offsetY = containerView!.bounds.height + bottomPadding - height
        var offsetX: CGFloat = 0.0
        switch style {
        case .borderdCorners(let width):
            offsetX = width
        case .simple:
            break
        }
        return CGRect(
            x: -offsetX,
            y: offsetY,
            width: UIScreen.main.bounds.width + offsetX,
            height: height)
    }
    
    var onDismiss: (() -> Void)?
    
    func initialize() {
        guard !initialized else {return}
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController));
        tapGestureRecognizer.cancelsTouchesInView = false;
        containerView?.addGestureRecognizer(tapGestureRecognizer);
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture));
        panGestureRecognizer.delegate = self;
        presentedView?.addGestureRecognizer(panGestureRecognizer);
        
        if #available(iOS 13.0, *) {}
        else {
            UIApplication.shared.statusBarView?.backgroundColor = ColorName.backgroundDark.color
        }
        
        containerView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        initialized = true;
    }

    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()

        switch style {
        case .borderdCorners(let width):
            presentedView?.roundCorners(corners: [.topLeft, .topRight],
                                        radius: 16,
                                        color: ColorName.grayBorder.color,
                                        width: width)
        case .simple:
            presentedView?.layer.cornerRadius = 12
            presentedView?.clipsToBounds = true

        }
    }
    
    func clearColor() {
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView?.backgroundColor = .clear;
            
            if #available(iOS 13.0, *) {}
            else {
                UIApplication.shared.statusBarView?.backgroundColor = ColorName.navigationBarTint.color
            }
            
        }) { (status) in
            DispatchQueue.main.async {
                self.onDismiss?();
            }
        }
    }
    
    @objc private func dismissController(sender: UIGestureRecognizer) {
        // dismiss if tapped outside of presentedViewController.
        let touchPoint = sender.location(in: presentedViewController.view);
        if !presentingViewController.view.frame.contains(touchPoint) {
            presentedViewController.dismiss(animated: true);
            clearColor();
        }
    }
    
    @objc private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        guard let presentedView = presentedView, let containerView = containerView else {return}
        
        let translation = recognizer.translation(in: presentedView);
        let y = presentedView.frame.minY;
        let height = containerView.bounds.height * heightPercent;
        let offset = containerView.bounds.height - height;
        
        presentedView.frame = CGRect(x: 0, y: (y + translation.y).clamped(min: offset), width: presentedView.frame.width, height: presentedView.frame.height);
        recognizer.setTranslation(CGPoint.zero, in: presentedView);
        
        if recognizer.state == .ended {
            guard presentedView.frame.origin.y < offset + 100 else {
                presentedViewController.dismiss(animated: true);
                self.clearColor();
                return;
            }
            
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction], animations: {
                presentedView.frame = CGRect(x: 0, y: offset, width: presentedView.frame.width, height: presentedView.frame.height);
            });
        }
    }
}

extension PullUpPresentationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isAtTop = (presentedViewController as? PullUpPresentationControllerDelegate)?.canDismiss ?? false
        let velocity = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: gestureRecognizer.view).y ?? 0
        
        return velocity > 0 && isAtTop
    }
}

 protocol PullUpPresentationControllerDelegate {
	var canDismiss: Bool { get }
}
