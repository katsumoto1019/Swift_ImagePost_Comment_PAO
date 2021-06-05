//
//  SpotClusterAnnotationView.swift
//  Pao
//
//  Created by Waseem Ahmed on 20/08/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import MapKit
//import Cluster

class SpotClusterAnnotationView: MKAnnotationView {
    
    private let boxInset = CGFloat(5)
    //    private let contentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 5)
    private let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    let imageSize = CGSize(width: 40, height: 40);
    private let labelSize = CGSize(width: 20, height: 20);
    private(set) var labelOffset:CGFloat = 7;
    
    var onClickCallback : ((_ spotId: String?) -> Void)? {
        didSet {
            setClickable();
        }
    }
    
    override var annotation: MKAnnotation? {
        willSet {
            if let annotation = annotation as? SpotClusterAnnotation {
                countLabel.text = annotation.title
                
                if let url = annotation.imageUrl {
                    imageView.kf.setImage(with: url);
                }
            }}}
    
    lazy var containerView: UIView = {
        let view = UIView(frame: CGRect.init(x: 0, y: 0,width: imageSize.width + labelOffset , height: imageSize.height + labelOffset));
        view.addSubview(imageView);
        view.addSubview(countLabel);
        view.backgroundColor = UIColor.clear;
        
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        imageView.contentMode = .scaleAspectFill;
        imageView.clipsToBounds = true;
        imageView.drawBorder(color: UIColor.white, borderWidth: 2, cornerRadius: 2);

        return imageView
    }()
    
    lazy var countLabel: UILabel = {
        let label = UILabel(frame: CGRect.init(origin: CGPoint.zero, size: labelSize))
        label.textColor = UIColor.white
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = ColorName.accent.color
        label.numberOfLines = 1
        label.textAlignment = .center;
        label.makeCornerRound()
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        return label
    }()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        addSubview(containerView)
        
        containerView.frame = CGRect.init(x: 0, y: 0, width: imageSize.width + labelOffset, height: imageSize.height + labelOffset);
        
        imageView.frame = containerView.bounds.inset(by: UIEdgeInsets.init(top: labelOffset, left: 0, bottom: 0, right: labelOffset))
        
        countLabel.frame = CGRect.init(x: containerView.frame.width - labelSize.width, y: 0, width: labelSize.width, height: labelSize.height);
        
        self.frame.size = containerView.frame.size;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
      
        imageView.image = nil
        countLabel.text = nil
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        /*
         If using the same annotation view and reuse identifier for multiple annotations, iOS will reuse this view by calling `prepareForReuse()`
         so the view can be put into a known default state, and `prepareForDisplay()` right before the annotation view is displayed. This method is
         the view's oppurtunity to update itself to display content for the new annotation.
         */
        if let annotation = annotation as? SpotClusterAnnotation {
            countLabel.text = annotation.title
            
            if let url = annotation.imageUrl {
                imageView.kf.setImage(with: url);
            }
        }
        
        // Since the image and text sizes may have changed, require the system do a layout pass to update the size of the subviews.
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // The containerview will not have a size until a `layoutSubviews()` pass is completed. As this view's overall size is the size
        // of the containerview plus a border area, the layout system needs to know that this layout pass has invalidated this view's
        // `intrinsicContentSize`.
        invalidateIntrinsicContentSize()
        
        // The annotation view's center is at the annotation's coordinate. For this annotation view, offset the center so that the
        // drawn arrow point is the annotation's coordinate.
        let contentSize = intrinsicContentSize
        
        //Moving view to left side so that it should point top-right corner at the lat/long coordinates.
        centerOffset = CGPoint(x: -(contentSize.width / 2), y: contentSize.height / 2)
        
        // Now that the view has a new size, the border needs to be redrawn at the new size.
        setNeedsDisplay()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = containerView.bounds.size
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        return size
    }
    
    private func setClickable() {
        imageView.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(handleTap(tapGesture:))));
        imageView.isUserInteractionEnabled = true;
    }
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        if let annotation = annotation as? SpotClusterAnnotation {
            onClickCallback?(annotation.spotId);
        }
    }
}
