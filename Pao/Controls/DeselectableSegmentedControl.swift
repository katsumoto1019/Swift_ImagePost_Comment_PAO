//
//  DeselectableSegmentedControl.swift
//  Pao
//
//  Created by Exelia Technologies on 06/07/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import UIKit
// REF: https://stackoverflow.com/questions/17652773/how-to-deselect-a-segment-in-segmented-control-button-permanently-till-its-click
class DeselectableSegmentedControl: UISegmentedControl {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let previousIndex = selectedSegmentIndex
        
        super.touchesEnded(touches, with: event)
        
        if previousIndex == selectedSegmentIndex {
            let touchLocation = touches.first!.location(in: self)
            
            if bounds.contains(touchLocation) {
                sendActions(for: .touchUpInside)
            }
        }
    }
}
