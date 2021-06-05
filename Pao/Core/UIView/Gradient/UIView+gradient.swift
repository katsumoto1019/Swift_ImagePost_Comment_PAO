//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 20.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

extension UIView {
    func linearGradient(
        colors: [CGColor],
        start: CGPoint = CGPoint(x: 0.0, y: 0.5),
        end: CGPoint = CGPoint(x: 1.0, y: 0.5)) -> CAGradientLayer {

        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colors
        gradient.startPoint = start
        gradient.endPoint = end
        gradient.cornerRadius = self.layer.cornerRadius

        return gradient
    }
}
