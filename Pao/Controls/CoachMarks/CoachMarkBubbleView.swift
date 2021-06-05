//
//  CustomCoachMarkBodyView.swift
//  Pao
//
//  Created by Waseem Ahmed on 24/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Instructions

// Custom coach mark body (with the secret-like arrow)
class CoachMarkBubbleView: UIView, CoachMarkBodyView {

    var nextControl: UIControl?
    
    var highlighted: Bool = false
    
    var hintLabel = UITextView()
    
    weak var highlightArrowDelegate: CoachMarkBodyHighlightArrowDelegate?
    
    private let gradientLayer:CAGradientLayer = CAGradientLayer();

    var clickCallback: (() -> Void)?
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    // MARK: - Initialization
    override init (frame: CGRect) {
        super.init(frame: frame)
        
        applyStyles();
        setupInnerViewHierarchy()
        drawBorder();
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = self.bounds;
    }
    
    // MARK: - Private methods
    fileprivate func setupInnerViewHierarchy() {
        self.addSubview(hintLabel)

        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(10)-[hintLabel]-(10)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil, views: ["hintLabel": hintLabel]))
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(10)-[hintLabel]-(10)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0),
                                                           metrics: nil, views: ["hintLabel": hintLabel]))
    }
    
    func applyStyles() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = ColorName.background.color
        
        self.clipsToBounds = true
        self.layer.cornerRadius = 4
        
        self.hintLabel.backgroundColor = UIColor.clear
        self.hintLabel.textColor = UIColor.white
        self.hintLabel.font = UIFont.app.withSize(13.0)
        self.hintLabel.isScrollEnabled = false
        self.hintLabel.textAlignment = .center
        self.hintLabel.layoutManager.hyphenationFactor = 1.0
        self.hintLabel.isEditable = false
        
        self.hintLabel.translatesAutoresizingMaskIntoConstraints = false
       // self.hintLabel.isUserInteractionEnabled = false
    }
    
    func setAttributedText(title: String?, description: String, alignment: NSTextAlignment = .center) {
        var text = description;
        if let title = title , !title.trim.isEmpty {
            text = String(format: "%@\n%@", title, description);
        }
        let titleRange = (text as NSString).range(of: title ?? "");
        let descriptionRange = (text as NSString).range(of: description);
        
        let paragraphStyle = NSMutableParagraphStyle.init()
        paragraphStyle.alignment = alignment;
        
        let attributedText = NSMutableAttributedString(string: text);
        attributedText.setAttributes([.paragraphStyle: paragraphStyle, .foregroundColor: ColorName.accent.color, .font: UIFont.appMedium.withSize(UIFont.sizes.normal)], range: titleRange)
        attributedText.setAttributes([.paragraphStyle:paragraphStyle,.foregroundColor: UIColor.white,.font: UIFont.app.withSize(UIFont.sizes.small)], range: descriptionRange);
        hintLabel.attributedText = attributedText;
    }
    
    func setText(title: String, alignment: NSTextAlignment = .center) {
        setAttributedText(title: nil, description: title, alignment: alignment);
    }
    
    func drawBorder() {
        layer.cornerRadius = 5.0;

        gradientLayer.colors = [ColorName.coachMarksBorderGradientFirst.color.cgColor,  ColorName.coachMarksBorderGradientSecond.color.cgColor]
        layer.insertSublayer(gradientLayer, at: 0);
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        clickCallback?();
        return false;
    }
}


// Transparent coach mark (text without background, cool arrow)
internal class CoachMarkArrow : UIView, CoachMarkArrowView {
    var isHighlighted: Bool = false
    
    var clickCallback: (() -> Void)?

    // MARK: - Initialization
    init(orientation: CoachMarkArrowOrientation) {
         super.init(frame: CGRect.zero)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(self.heightAnchor.constraint(equalToConstant: 25));
        self.addConstraint(self.widthAnchor.constraint(equalToConstant: 20));
  }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }
    
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.minY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.maxY))
        context.closePath()
    
  
        context.setFillColor(ColorName.coachMarksBorderGradientSecond.color.cgColor)
        context.fillPath()
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        clickCallback?();
        return false;
    }
}
