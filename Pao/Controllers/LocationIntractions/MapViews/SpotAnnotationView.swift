//
//  SpotAnnotationView.swift
//  Pao
//
//  Created by Waseem Ahmed on 09/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import MapKit

class SpotAnnotationView: SpotClusterAnnotationView {
    override var labelOffset: CGFloat {
        get { return 0 }
        set { }
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        countLabel.removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        /*
         If using the same annotation view and reuse identifier for multiple annotations, iOS will reuse this view by calling `prepareForReuse()`
         so the view can be put into a known default state, and `prepareForDisplay()` right before the annotation view is displayed. This method is
         the view's oppurtunity to update itself to display content for the new annotation.
         */
        if let annotation = annotation as? SpotAnnotation {
            countLabel.text = nil
            //            imageView.drawBorder(color: UIColor.white, borderWidth: 2, cornerRadius: 2);
            
            if let url = annotation.imageUrl {
                imageView.kf.setImage(with: url);
            }
        }
        
        // Since the image and text sizes may have changed, require the system do a layout pass to update the size of the subviews.
        setNeedsLayout()
    }
    
    @objc override func handleTap(tapGesture: UITapGestureRecognizer) {
        if let annotation = annotation as? SpotAnnotation {
            onClickCallback?(annotation.spotId);
        }
    }
}
