//
//  IsaoTextField.swift
//  TextFieldEffects
//
//  Created by Raúl Riera on 29/01/2015.
//  Copyright (c) 2015 Raul Riera. All rights reserved.
//

import UIKit

/**
 An IsaoTextField is a subclass of the TextFieldEffects object, is a control that displays an UITextField with a customizable visual effect around the lower edge of the control.
 */
@IBDesignable open class IsaoTextField: TextFieldEffects, UITextFieldDelegate {
    

    /**
     The color of the border when it has no content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderInactiveColor: UIColor? {
        didSet {
            updateBorder()
        }
    }
    
    /**
     The color of the border when it has content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var borderActiveColor: UIColor? = ColorName.accent.color {
        didSet {
            updateBorder()
        }
    }
    
    /**
     The color of the border when it has content.
     
     This property applies a color to the lower edge of the control. The default value for this property is a clear color.
     */
    @IBInspectable dynamic open var errorTextColor: UIColor? {
        didSet {
            updateError()
        }
    }
    
    /**
     The scale of the error font.
     
     This property determines the size of the error label relative to the font size of the text field.
     */
    @IBInspectable dynamic open var errorFontScale: CGFloat = 0.7 {
        didSet {
            updateError()
        }
    }
    
     open var error: String? {
        didSet {
            updateError()
        }
    }
    
    var nextTextField: IsaoTextField? {
        didSet{
            returnKeyType = .next;
        }
    }
    
    var endEdittingCallback: ((_ textField: IsaoTextField) -> Void?)?

    var textChangedCallback: ((_ textField: IsaoTextField) -> Void?)?

    var returnKeyPressed: ((_ textField: IsaoTextField) -> Bool)? {
        didSet {
            delegate = self;
        }
    }

    override open var bounds: CGRect {
        didSet {
            updateBorder()
            updateError()
        }
    }

    private let borderThickness: (active: CGFloat, inactive: CGFloat) = (2, 1)
    private let errorInsets = CGPoint(x: 6, y: -16)
    private let textFieldInsets = CGPoint(x: 6, y: -8)
    private let inactiveBorderLayer = CALayer()
    private let activeBorderLayer = CALayer()
    
    
    // MARK: - TextFieldEffects
    
    override open func drawViewsForRect(_ rect: CGRect) {
        let frame = CGRect(origin: .zero, size: CGSize(width: rect.size.width, height: rect.size.height))
        
        errorLabel.frame = frame.insetBy(dx: errorInsets.x, dy: errorInsets.y)
        errorLabel.font = errorFontFromFont(font!)
        errorLabel.numberOfLines = 2;
        updateBorder()
        updateError()
        
        layer.addSublayer(inactiveBorderLayer)
        layer.addSublayer(activeBorderLayer)

        addSubview(errorLabel)
    }
    
    override open func animateViewsForTextEntry() {
            performBorderAnimationWithColor()
    }
    
    override open func animateViewsForTextDisplay() {
            performBorderAnimationWithColor()
    }
    
    // MARK: - Private
    
    private func updateBorder() {
     
        inactiveBorderLayer.frame = rectForBorder(borderThickness.inactive, isFilled: true)
        inactiveBorderLayer.backgroundColor = borderInactiveColor?.cgColor
        
        activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: false)
        activeBorderLayer.backgroundColor = borderActiveColor?.cgColor
    }
    
    private func updateError() {
        errorLabel.text = error
        errorLabel.textColor = errorTextColor
        errorLabel.textAlignment = .left;
        //errorLabel.sizeToFit()
        layoutErrorInTextRect()
        
        if isFirstResponder {
            animateViewsForTextEntry()
        }
    }
    
    
    private func errorFontFromFont(_ font: UIFont) -> UIFont! {
        let smallerFont = UIFont(name: font.fontName, size: font.pointSize * errorFontScale)
        return smallerFont
    }
    
    override open func textFieldDidBeginEditing() {
        super.textFieldDidBeginEditing()
        
        error = nil;
    }
    
    override open func textFieldDidEndEditing() {
        super.textFieldDidEndEditing()
        
       // nextTextField?.becomeFirstResponder()
        endEdittingCallback?(self);
    }
    
    private func rectForBorder(_ thickness: CGFloat, isFilled: Bool) -> CGRect {
        var newRect:CGRect

        if isFilled {
            newRect = CGRect(x: 0, y: bounds.size.height - font!.lineHeight + textFieldInsets.y - thickness, width: bounds.size.width, height: thickness)
        } else {
            newRect = CGRect(x: 0, y: bounds.size.height - font!.lineHeight + textFieldInsets.y - thickness, width: 0, height: thickness)
        }
          return newRect
    }
    
    private func layoutErrorInTextRect() {
        let textRect = self.textRect(forBounds: bounds)
        var originX = textRect.origin.x
        var size = errorLabel.sizeThatFits(CGSize(width:textRect.width, height:bounds.height));
        if size.height > 30 { size.width = textRect.width; }
        originX += textRect.size.width - size.width
        errorLabel.frame = CGRect(x: originX, y: inactiveBorderLayer.frame.origin.y + 2,
                                  width: size.width, height: size.height)
    }
    
    private func performBorderAnimationWithColor() {
        activeBorderLayer.frame = rectForBorder(borderThickness.active, isFilled: isFirstResponder)
    }
    
    // MARK: - Overrides
        
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - font!.lineHeight + textFieldInsets.y)
        return newBounds.insetBy(dx: textFieldInsets.x, dy: 0)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let newBounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - font!.lineHeight + textFieldInsets.y)
        
        return newBounds.insetBy(dx: textFieldInsets.x, dy: 0)
    }
    
    
    open func beginEditting() {
        drawViewsForRect(frame);
        becomeFirstResponder()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
         nextTextField?.becomeFirstResponder()
        
        if returnKeyPressed != nil {
            return returnKeyPressed!(self)
        }
        return true;
    }
    
    override  open func textDidChanged() {
        error = nil;
        textChangedCallback?(self)
    }
}
