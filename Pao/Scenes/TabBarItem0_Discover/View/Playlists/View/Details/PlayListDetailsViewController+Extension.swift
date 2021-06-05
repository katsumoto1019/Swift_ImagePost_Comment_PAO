//
//  PlayListDetailsViewController+Extension.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/12/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//
import UIKit
import Instructions

extension PlayListDetailsViewController: CoachMarksControllerDataSource, CoachMarksControllerDelegate {
    
    enum SpotTutorialType {
        case tip
        case save
    }
    
    // MARK: - Internal methods
    
    func setTutorials() {
        coachMarksController.dataSource = self
        coachMarksController.overlay.backgroundColor = ColorName.coachMarksPlaylistsBackground.color
        coachMarksController.overlay.isUserInteractionEnabled = true
    }
    
    func startTutorial(type: SpotTutorialType) {
        
        tutorialType = type
        
        switch type {
        case .tip:
            if !UserDefaults.bool(key: UserDefaultsKey.doneTutorialForSpotTip.rawValue) {
                UserDefaults.save(value: true, forKey: UserDefaultsKey.doneTutorialForSpotTip.rawValue)
                coachMarksController.start(in: .window(over: self))
            }
        case .save:
            if !UserDefaults.bool(key: UserDefaultsKey.doneTutorialForSpotSaveAction.rawValue) {
                UserDefaults.save(value: true, forKey: UserDefaultsKey.doneTutorialForSpotSaveAction.rawValue)
                coachMarksController.start(in: .window(over: self))
            }
        }
    }

    // MARK: - CoachMarksControllerDataSource implementation

    func numberOfCoachMarks(for coachMarksController: CoachMarksController) -> Int {
        return 1
    }


    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkViewsAt index: Int, madeFrom coachMark: CoachMark) -> (bodyView: (UIView & CoachMarkBodyView), arrowView: (UIView & CoachMarkArrowView)?) {

        switch tutorialType! {
        case .tip:
            let frame = frameCoachMark(forType: .tip)
            let coachMarkBodyView = CoachMarkOverlayView(frame: frame)
            coachMarkBodyView.hintLabel.text = L10n.PlayListDetailsViewController.CoachMarkBodyView.HintLabel.text
            coachMarkBodyView.iconImageView.image = Asset.Assets.Icons.point.image
            coachMarkBodyView.clickedCallback = {
                let indexPath = IndexPath(row: 2, section: 0)
                self.coachMarksController.flow.showNext()
                if let cell = self.manualSpotViewController.spotCollectionViewController.collectionView.cellForItem(at: indexPath) as? SpotCollectionViewCell {
                    cell.goButton.isHidden = true
                    cell.expand()
                }
            }
            return (bodyView: coachMarkBodyView, arrowView: nil)
        case .save:
            let coachMarkBodyView = CoachMarkBubbleView()
            coachMarkBodyView.setAttributedText(
                title: "\(L10n.PlayListDetailsViewController.CoachMarkBodyView.title):",
                description: L10n.PlayListDetailsViewController.CoachMarkBodyView.description,
                alignment: .left)
            return (bodyView: coachMarkBodyView, arrowView: nil)
        }
    }

    func coachMarksController(_ coachMarksController: CoachMarksController, coachMarkAt index: Int) -> CoachMark {

        switch tutorialType! {
        case .tip:

            var frame = frameCoachMark(forType: tutorialType!)
            frame.origin.x = (view.frame.size.width - frame.width) / 2
            var coachmark = coachMarksController.helper.makeCoachMark(for: nil, pointOfInterest: CGPoint(x: frame.midX, y: frame.midY))
            coachmark.maxWidth = frame.width
            coachmark.cutoutPath = UIBezierPath(rect: frame)
            coachmark.gapBetweenCoachMarkAndCutoutPath = -frame.height
            coachmark.arrowOrientation = .top
            return coachmark

        case .save:
            let frame = frameCoachMark(forType: tutorialType!)
            var coachmark = coachMarksController.helper.makeCoachMark(for: nil, pointOfInterest: CGPoint(x: frame.midX, y: frame.midY))

            coachmark.cutoutPath = UIBezierPath.init(ovalIn: frame.insetBy(dx: -4, dy: -4))
            coachmark.gapBetweenCoachMarkAndCutoutPath = 10.0
            coachmark.arrowOrientation = .bottom
            return coachmark
        }
    }

    // MARK: - Private methods

    private func frameCoachMark(forType type: SpotTutorialType) -> CGRect {
        var cellFrame: CGRect!

        guard
            let index = self.tutorialTypeIndexes?[type],
            let collectionView = manualSpotViewController.spotCollectionViewController.collectionView,
            let cell = collectionView.cellForItem(at: IndexPath(row: index - 1, section: 0)) as? SpotCollectionViewCell else { return .zero }

        switch type {
        case .tip:
            cellFrame = cell.containerView.convert(cell.containerView.bounds, to: view)

        case .save:
            cellFrame = cell.saveButton.convert(cell.saveButton.bounds, to: view)

            let diff = abs(cellFrame.size.height - cellFrame.size.width) / 2
            let sizeValue = max(cellFrame.size.width, cellFrame.size.height) - diff
            cellFrame.size = CGSize(width: sizeValue, height: sizeValue)
            cellFrame.origin.x = cellFrame.origin.x - (diff / 2)
            cellFrame.origin.y = cellFrame.origin.y + (diff / 2)
        }

        return cellFrame
    }
}
