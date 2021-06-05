//
//  UIViewExtensions.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

extension UIView {
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        
        let backgroundCGColor = backgroundColor?.cgColor
        backgroundColor = nil
        layer.backgroundColor =  backgroundCGColor
    }
    
   @objc func circleShadow(offset: CGSize = .zero, color: UIColor = .black, radius: CGFloat = 3, opacity: Float = 1) {
        layer.cornerRadius = frame.size.height / 2
       addShadow(offset: offset, color: color, radius: radius, opacity: opacity)
    }
    
    func addInnerShadow(radius: CGFloat, opecity: Float,frame:CGRect? = nil) -> CALayer {
        let innerShadowLayer = CALayer()
        innerShadowLayer.frame = frame != nil ? frame! : self.bounds
        let path = UIBezierPath(rect: innerShadowLayer.bounds.insetBy(dx: -20, dy: -20))
        let innerPart = UIBezierPath(rect: innerShadowLayer.bounds).reversing()
        path.append(innerPart)
        innerShadowLayer.shadowPath = path.cgPath
        innerShadowLayer.masksToBounds = true
        innerShadowLayer.shadowColor = UIColor.black.cgColor
        innerShadowLayer.shadowOffset = CGSize.zero
        innerShadowLayer.shadowOpacity = opecity
        innerShadowLayer.shadowRadius = radius
        self.layer.addSublayer(innerShadowLayer)
        return innerShadowLayer
    }
    
    func makeCornerRound(cornerRadius: CGFloat? = nil) {
        if let cornerRadius = cornerRadius {
            self.layer.cornerRadius = cornerRadius
            
        } else {
            if self.frame.size.height <= self.frame.size.width {
                self.layer.cornerRadius = self.frame.size.height / 2
            } else {
                self.layer.cornerRadius = self.frame.size.width / 2
            }
        }
        
        self.layer.masksToBounds = true
    }
    
    func drawDashedBorder(color: UIColor) {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = color.cgColor
        borderLayer.lineWidth = 2
        borderLayer.fillColor = nil
        borderLayer.lineDashPattern = [10, 5]
        layer.addSublayer(borderLayer)
        borderLayer.frame = self.bounds
        borderLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5).cgPath
    }
    
    func drawBorder(color: UIColor, borderWidth: CGFloat = 1, cornerRadius: CGFloat = 0.0) {
        layer.cornerRadius = cornerRadius
        layer.borderColor = color.cgColor
        layer.borderWidth = borderWidth
    }
    
    var isFullScreen: Bool {
        return bounds.equalTo(UIScreen.main.bounds)
    }
    
    
    func addBorder(edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
        let border = CALayer()
        switch edge {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: frame.width, height: thickness)
        case .bottom:
            border.frame = CGRect(x: 0, y: frame.height - thickness, width: frame.width, height: thickness)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: thickness, height: frame.height)
        case .right:
            border.frame = CGRect(x: frame.width - thickness, y: 0, width: thickness, height: frame.height)
        default:
            break
        }
        
        border.backgroundColor = color.cgColor
        
        layer.addSublayer(border)
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat, color: UIColor, width: CGFloat = 1) {
        let bounds = self.bounds
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
        let frameLayer = CAShapeLayer()
        frameLayer.frame = bounds
        frameLayer.path = maskPath.cgPath
        frameLayer.strokeColor = color.cgColor
        frameLayer.lineWidth = width
        frameLayer.fillColor = nil
        self.layer.addSublayer(frameLayer)
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle: Bundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
        ).instantiate(withOwner: nil, options: nil)[0] as? UIView
    }
}

extension UIView {
    func constraintToFit(inContainerView containerView: UIView, inset: UIEdgeInsets = UIEdgeInsets.zero) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: containerView.topAnchor, constant: inset.top).isActive = true
        rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: inset.right).isActive = true
        bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: inset.bottom).isActive = true
        leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: inset.left).isActive = true
    }
    
    func constraintToFitHorizontally(inContainerView containerView: UIView, inset: UIEdgeInsets = UIEdgeInsets.zero) {
        translatesAutoresizingMaskIntoConstraints = false
        rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: inset.right).isActive = true
        leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: inset.left).isActive = true
    }
    
    func constraintToFitVertically(inContainerView containerView: UIView, inset: UIEdgeInsets = UIEdgeInsets.zero) {
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: containerView.topAnchor, constant: inset.top).isActive = true
        bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: inset.bottom).isActive = true
    }
    
    func constraintToFitInCenter(inContainerView containerView: UIView, inset: UIEdgeInsets = UIEdgeInsets.zero) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: containerView.centerXAnchor, constant: inset.top).isActive = true
        centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: inset.bottom).isActive = true
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
    
    /// find first view  of given type in the hierchy of subViews
       /// - Parameter type: type of view
       /// - Parameter superView: superview
       func findSubView<T: UIView>(ofType type: T.Type) -> T? {
           for view in subviews {
               if let typedView = view as? T {
                   return typedView
               }
               
            if let typedView = view.findSubView(ofType: type) {
                   return typedView
               }
           }
           return nil
       }
}

extension UIApplication {
    var hasTopNotch: Bool {
        if #available(iOS 13.0,  *) {
            return UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.safeAreaInsets.top ?? 0 > 20
        }else{
         return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
    }
}
