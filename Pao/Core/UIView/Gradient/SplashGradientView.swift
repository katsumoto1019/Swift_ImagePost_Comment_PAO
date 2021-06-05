//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 20.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class SplashGradientView: UIView {

    // MARK: - Internal properties

    var style: ApplicationStyle? {
        didSet {
            guard let style = self.style else { return }
            configure(style: style, cornerRadius: radius ?? 0.0)
        }
    }

    var radius: CGFloat? {
        didSet {
            guard let style = self.style, let radius = self.radius else { return }
            configure(style: style, cornerRadius: radius)
        }
    }

    var location: [NSNumber] = []
    var startPoint: CGPoint = .zero
    var endPoint: CGPoint = .zero

    // MARK: - Private properties

    private weak var image: CALayer?
    private weak var gradient: CAGradientLayer?

    // MARK: Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        addImage()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addImage()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = bounds
        image?.frame = bounds
    }

    // MARK: - Internal methods

    func removeGradientTo(splashView: SplashGradientView) {
        guard let gradient = gradient else {
            return
        }

        gradient.removeFromSuperlayer()
        splashView.layer.insertSublayer(gradient, at: 2)
    }

    func moveGradientOnSelf() {
        guard let gradient = gradient, gradient.superlayer != layer else {
            return
        }

        gradient.removeFromSuperlayer()
        layer.insertSublayer(gradient, at: 1)
    }

    var alphaGradient: CGFloat = 1.0 {
        didSet {
            gradient?.opacity = Float(alphaGradient)
        }
    }

    var alphaContent: CGFloat = 1.0 {
        didSet {
            gradient?.opacity = Float(alphaContent)
            image?.opacity = Float(alphaContent)
        }
    }

    // MARK: - Private methods

    private func configure(style: ApplicationStyle, cornerRadius radius: CGFloat) {

        var gradient: CAGradientLayer

        if startPoint != .zero, endPoint != .zero, !location.isEmpty {
            gradient = CAGradientLayer.customDirectionGradient(
                style: style,
                startPoint: startPoint,
                endPoint: endPoint,
                locations: location
            )
        } else {
            gradient = CAGradientLayer.verticalGradient(style: style)
        }

        self.layer.insertSublayer(gradient, at: 0)
        gradient.frame = bounds
        gradient.cornerRadius = radius

        self.gradient?.removeFromSuperlayer()
        self.gradient = gradient
    }

    private func addImage() {
        let image = CALayer()
        image.contentsGravity = .center
        image.contentsScale = UIScreen.main.scale
        image.contentsGravity = .resizeAspectFill

        self.image = image
        self.layer.insertSublayer(image, at: 1)
    }
}
