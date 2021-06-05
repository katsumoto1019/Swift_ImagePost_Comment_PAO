//
//  TabBarController+Coachmark.swift
//  Pao
//
//  Created by Waseem Ahmed on 07/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Instructions

extension TabBarController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    // MARK: - Internal methods
    
    func setupTutorials() {
        coachMarksController.dataSource = self
        coachMarksController.overlay.backgroundColor = ColorName.coachMarksBackground.color
        coachMarksController.overlay.isUserInteractionEnabled = true
    }
    
    func startTutorials() {
        guard !UserDefaults.bool(key: UserDefaultsKey.doneTutorialForTabs.rawValue) else {
            showNewFeatureAlertIfNeeded()
            return
        }
        UserDefaults.save(value: true, forKey: UserDefaultsKey.doneTutorialForTabs.rawValue)
        UserDefaults.save(value: true, forKey: UserDefaultsKey.isShowPlaylistFeature.rawValue)
        //coachMarksController.start(in: .window(over: self))
        showWelcomeMessage()
    }
    
    // MARK: - CoachMarksControllerDataSource implementation
    
    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 3
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {
        
        let coachMarkBodyView = CoachMarkBubbleView()
        let coachMarkArrowView = CoachMarkArrow(orientation: .bottom)
        
        coachMarkBodyView.clickCallback = {
            self.coachMarksController.flow.showNext()
        }
        
        coachMarkArrowView.clickCallback = {
            self.coachMarksController.flow.showNext()
        }
        
        switch index {
        case 1:
            coachMarkBodyView.setText(title: L10n.TabBarController.CoachMarkBodyView.findPeopleToAdd)
        case 0:
            coachMarkBodyView.setText(title: L10n.TabBarController.CoachMarkBodyView.shareYourSpot)
        default:
            coachMarkBodyView.setText(title: L10n.TabBarController.CoachMarkBodyView.swipeSpots)
        }
        return (bodyView: coachMarkBodyView, arrowView: coachMarkArrowView)
    }
    
    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {
        let frame = frameFor(caochMarkAt: index)
        let pointOfInterest = CGPoint(x: frame.midX, y: frame.origin.y)
        var coachmark = coachMarksController.helper.makeCoachMark(for: nil, pointOfInterest: pointOfInterest)
        let rect = index == 0 ? frame : frame.insetBy(dx: 6, dy: 0)
        
        coachmark.cutoutPath = UIBezierPath(rect: rect)
        coachmark.gapBetweenCoachMarkAndCutoutPath = 2.0
        coachmark.gapBetweenBodyAndArrow = 0.0
        coachmark.arrowOrientation = .bottom
        return coachmark
    }
    
    // MARK: - Private methods
    
    private func frameFor(caochMarkAt index: Int) -> CGRect {
        let boundSize = tabBar.bounds.size
        let size = CGSize(width: boundSize.width / 5, height: boundSize.height)
        var frame = CGRect(origin: tabBar.frame.origin, size: size)
        
        switch index {
        case 0:
            frame = postButton.convert(postButton.bounds, to: self.view)
        case 1:
            frame.origin = CGPoint(x: frame.width , y: frame.origin.y)
            frame.size.height = 49
        case 2:
            frame.size.height = 49
        default:
            break
        }
        return frame
    }
}
