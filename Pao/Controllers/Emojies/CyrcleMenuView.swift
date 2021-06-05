//
//  CyrcleMenuView.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 20.08.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

final class CyrcleMenuView: UIView {
    
    let emptyButton = EmojiButton()
    var buttonArray: [EmojiButton] = []
    var labelsArray: [UILabel] = []
    var chooseEmoji: ((Emoji) -> ())?
    let cyrclePointCount = 10
    var withText: Bool = false
    let slowMotion = 1.0
    
    private class LabelTapGesture: UITapGestureRecognizer {
        var emoji: Emoji?
    }
    
    enum Mode {
        case left
        case right
    }
    
    var mode: Mode = .right
    
    init() {
        super.init(frame: CGRect.zero)
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(dissmis)))
        self.addSubview(emptyButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showWith(emojies: [Emoji], center: CGPoint, _withText: Bool = false) {
        self.withText = _withText
        emptyButton.center = center
        emptyButton.onShowMenu = {
            self.dissmis()
        }
        buttonArray.forEach { $0.removeFromSuperview() }
        labelsArray.forEach { $0.removeFromSuperview() }
        labelsArray = []
        
        buttonArray = emojies.sorted().compactMap {
            let button = EmojiButton(emoji: $0)
            button.onClick = { _, emoji in
                self.select(emoji: emoji)
            }
            labelsArray.append(
                UILabel(text: $0.text,
                        font: UIFont.appMedium.withSize(14.0),
                        color: ColorName.textWhite.color,
                        textAlignment: .left))
            
            return button
        }
        
        let points = getCirclePoints(center: center, radius: 60.0, n: cyrclePointCount)
        
        self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        UIView.animate(
            withDuration: 0.2 * slowMotion,
            delay: 0.0,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.75)
            }
        )
        
        buttonArray.enumerated().forEach { index, button in
            button.center = points[index]
            self.addSubview(button)
            if self.withText {
                self.addLabels(index: index, center: center)
            }
            button.delta = CGPoint(x: center.x-points[index].x, y: center.y-points[index].y)
            button.transform = CGAffineTransform(scaleX: 0.25, y: 0.25).concatenating(CGAffineTransform(translationX: button.delta.x, y: button.delta.y))
            
            UIView.animate(
                withDuration: 0.2 * slowMotion,
                delay: 0.02 * slowMotion * Double(index),
                options: [UIView.AnimationOptions.curveEaseInOut],
                animations: {
                    button.transform = .identity
                    if self.withText {
                        self.labelsArray[index].alpha = 1;
                    }
                }
            )
        }
    }
    
    func addLabels(index: Int, center: CGPoint) {
        let label: UILabel = self.labelsArray[index]
        label.alpha = 0;
        label.isUserInteractionEnabled = true
        if let emoji = self.buttonArray[index].emoji  {
            let recognizer = LabelTapGesture(target: self, action: #selector(self.selectText(sender:)))
            recognizer.emoji = emoji
            label.addGestureRecognizer(recognizer)
        }
        self.addSubview(label)
        label.sizeToFit()
        label.tag = index
        let lastElementOffset: CGFloat = 6.0
        if center.x > self.center.x {
            let labelPoints = self.getCirclePoints(center: center, radius: 60.0, n: cyrclePointCount, mode: .left)
            if index == labelPoints.count - 1 {
                label.center.y = labelPoints[index].y + lastElementOffset
            } else if index == 0 {
                label.center.y = labelPoints[index].y - lastElementOffset
            } else {
                label.center.y = labelPoints[index].y
            }
            label.frame.origin.x = labelPoints[index].x - label.frame.size.width
        } else {
            if index == self.buttonArray.count - 1 {
                label.center.y = self.buttonArray[index].frame.center.y + lastElementOffset
            } else if index == 0 {
                label.center.y = self.buttonArray[index].frame.center.y - lastElementOffset
            } else {
                label.center.y = self.buttonArray[index].frame.center.y
            }
            label.frame.origin.x = self.buttonArray[index].frame.origin.x + 40
        }
    }
    
    func getCirclePoints(center: CGPoint,
                         radius: CGFloat,
                         n: Int,
                         from: Double = 0.0,
                         to: Double = 360.0,
                         mode: Mode = .right) -> [CGPoint] {
        var result: [CGPoint] = stride(from: from, to: to, by: (to - from) / Double(n)).map {
            let bearing: CGFloat = CGFloat($0) * .pi / 180.0
            
            let x = center.x + radius * cos(bearing)
            let y = center.y + radius * sin(bearing)
            return CGPoint(x: x, y: y)
        }
        
        switch mode {
        case .left:
            result.sort(by: { $0.x < $1.x })
        case .right:
            result.sort(by: { $0.x > $1.x })
        }
        return result.prefix(5).sorted(by: { $0.y < $1.y })
    }
    
    @objc
    private func selectText(sender: LabelTapGesture) {
        guard let emoji = sender.emoji else {
            return
        }
        select(emoji: emoji)
    }
    
    private func select(emoji: Emoji) {
        chooseEmoji?(emoji)
        dissmis()
    }
    
    
    @objc
    func dissmis() {
        UIView.animate(
            withDuration: 0.15 * slowMotion,
            delay: 0.0,
            options: [UIView.AnimationOptions.curveEaseInOut],
            animations: {
                self.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            }
        )
        
        buttonArray.reversed().enumerated().forEach { index, button in
            UIView.animate(
                withDuration: 0.15 * slowMotion,
                delay: 0.015 * slowMotion * Double(index),
                options: [UIView.AnimationOptions.curveEaseInOut],
                animations: {
                    button.transform = CGAffineTransform(scaleX: 0.25, y: 0.25).concatenating(CGAffineTransform(translationX: button.delta.x, y: button.delta.y))
                    if self.withText {
                        self.labelsArray.reversed()[index].alpha = 0;
                    }
                },
                completion: { _ in
                    button.removeFromSuperview()
                    if(index == self.buttonArray.count - 1) {
                        self.removeFromSuperview()
                    }
                }
            )
        }
    }
}
