//
//  NewSpotImageSelectionViewController+Expension.swift
//  Pao
//
//  Created by Waseem Ahmed on 07/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

//Mark - translating CarousalContainerView
extension NewSpotImageSelectionViewController {
    
    //CarousalContainerBottomView gesture handlers
    func handlePaneGesture(recognizer: UIPanGestureRecognizer) {
        if let swipedView = recognizer.view, swipedView == carouselContainerBottomView {
            let translation = recognizer.translation(in: self.view);
            
            _ = translatesCarosalContainer(value: translation.y);
            recognizer.setTranslation(CGPoint.zero, in: self.view);
            if recognizer.state == .ended {
                animateCarosalContainerToEnd(with: recognizer.velocity(in: self.view));
            }
        }
    }
    
    func handleTapGesture(recognizer: UITapGestureRecognizer) {
        guard topLayoutConstraint.constant != 0 else {return;}
        topLayoutConstraint.constant = 0;
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
    ///
    
    //CollectionView scroll Handler
    func scrolledCollection(at position: CGPoint?, translation: CGPoint?, contentOffset: CGPoint?, velocity: CGPoint?) -> Bool {
        
        guard let position = position, let translation = translation ,let contentOffset = contentOffset else {
            isMovingUpperView = false;
            lastTranslation = nil;
            animateCarosalContainerToEnd(with: velocity);
            return false;
        }
        
        let positionInView = self.view.convert(position, from: self.imagePickerContainerView);
        
        if isMovingUpperView || carouselContainerView.frame.contains(positionInView) {
            
            guard lastTranslation != nil else {
                lastTranslation = translation;
                return false;
            }
            
            isMovingUpperView = translatesCarosalContainer(value: -(lastTranslation!.y - translation.y));
            
            lastTranslation = translation;
            
        } else {
            if contentOffset.y < 0 || !isCarosalContainerAtEnd() {
                return translatesCarosalContainer(value: -contentOffset.y);
            }
            lastTranslation = nil;
        }
        
        return isMovingUpperView;
    }
    ///
    
    private  func translatesCarosalContainer(value: CGFloat) -> Bool {
        var newY = topLayoutConstraint.constant +  value;
        if newY > 0 {newY = 0;}
        if newY < -(carouselContainerView.bounds.height - carouselContainerBottomView.bounds.height) { newY = -(carouselContainerView.bounds.height - carouselContainerBottomView.bounds.height); }
        topLayoutConstraint.constant = newY;
        return !(newY == 0 || newY == -(carouselContainerView.bounds.height - carouselContainerBottomView.bounds.height));
    }
    
    private func animateCarosalContainerToEnd(with velocity: CGPoint?) {
        
        //        guard topLayoutConstraint.constant != -(carouselContainerView.bounds.height - carouselContainerBottomView.bounds.height), topLayoutConstraint.constant != 0 else {return;}
        guard !isCarosalContainerAtEnd() else {return;}
        
        if velocity == nil || velocity!.y == 0 {
            if topLayoutConstraint.constant < -(carouselContainerView.bounds.height / 2) {
                animateCarousalContainerToTop();
            }else {
                animateCarousalContainerToBottom();
            }
        } else if velocity!.y < 0 {
                animateCarousalContainerToTop();
        } else {
                animateCarousalContainerToBottom();
        }
    }
    
    private func animateCarousalContainerToTop() {
        topLayoutConstraint.constant = -(carouselContainerView.bounds.height - carouselContainerBottomView.bounds.height);
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
    
    private func animateCarousalContainerToBottom() {
        topLayoutConstraint.constant = 0;
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded();
        }
    }
    
    private func isCarosalContainerAtEnd() -> Bool {
        return topLayoutConstraint.constant == -(carouselContainerView.bounds.height - carouselContainerBottomView.bounds.height) || topLayoutConstraint.constant == 0;
    }
}

