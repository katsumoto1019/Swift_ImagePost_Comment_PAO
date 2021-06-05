//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 20.05.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

struct GradientColors {
    static var popUp: [CGColor] = [#colorLiteral(red: 0.01176470588, green: 0.8352941176, blue: 0.631372549, alpha: 1), #colorLiteral(red: 0.003921568627, green: 0.5882352941, blue: 0.4431372549, alpha: 1)]
	static var worldBackground: [CGColor] = [ #colorLiteral(red: 0, green: 0.1882352941, blue: 0.1411764706, alpha: 1), #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)]
    
    static func colorsForSyle(_ style: ApplicationStyle) -> [CGColor] {
        switch style {
        case .playListPopUp: return popUp
		case .playListBackground: return worldBackground
        }
    }
}
