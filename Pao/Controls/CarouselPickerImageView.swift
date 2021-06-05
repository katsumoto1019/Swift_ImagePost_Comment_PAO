//
//  CarouselPickerImageView.swift
//  Pao
//
//  Created by MACBOOK PRO on 26/08/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import CropViewController

class CarouselPickerImageView: UIImageView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    weak var delegate: CarouselPickerImageViewDelegate?
    
    var aspectRatio: CGSize?
    
    var cropData: CropData?
    
    var completionCallback: ((_ image: UIImage?)->Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCropController));
        self.addGestureRecognizer(tapGestureRecognizer);
        
        self.isUserInteractionEnabled  = true;
        
        self.contentMode = .scaleAspectFill;
        self.clipsToBounds = true;
        
        self.isUserInteractionEnabled = false;
    }
    
    @objc func showCropController() {
        if cropData != nil && cropData?.originalImage == nil {
            self.cropData?.originalImage = self.image!
        }
        
        let cropViewController = CropViewController(image: ((self.cropData?.originalImage) != nil) ? self.cropData!.originalImage! : self.image!);
        cropViewController.aspectRatioPickerButtonHidden = true;
        cropViewController.rotateButtonsHidden = true;
        cropViewController.resetAspectRatioEnabled = false;
        if let aspectRatio = aspectRatio {
            cropViewController.customAspectRatio = aspectRatio;
        }
        
        if let cropData = self.cropData {
            cropViewController.customAspectRatio = CGSize(width: 828, height: 1292)
            cropViewController.aspectRatioLockEnabled = true
            cropViewController.resetAspectRatioEnabled = false

            if let cropFrame = cropData.cropFrame {
                cropViewController.imageCropFrame = cropFrame
            }
            if let cropAngle = cropData.cropAngle {
                cropViewController.angle = cropAngle
            }
        }
        
        cropViewController.delegate = self;
        delegate?.showCropper(cropViewController: cropViewController);
    }
}

extension CarouselPickerImageView: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        self.cropData?.cropAngle = angle
        self.cropData?.cropFrame = cropRect
        self.cropData?.cropedImage = image
        
        cropViewController.dismiss(animated: false);
        self.image = image;
    }
}

protocol CarouselPickerImageViewDelegate: class {
    func showCropper(cropViewController: CropViewController);
}
