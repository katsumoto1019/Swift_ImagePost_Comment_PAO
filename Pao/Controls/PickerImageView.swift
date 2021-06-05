//
//  PickerImageView.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/23/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import CropViewController

class PickerImageView: UIImageView, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    weak var delegate: UIViewController?
    private(set) var isChanged = false;
    
    var useCircleCrop = false;
    var aspectRatio: CGSize?
    
    var completionCallback: ((_ image: UIImage?)->Void)?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(pickImage));
        self.addGestureRecognizer(tapGestureRecognizer);
        
        self.isUserInteractionEnabled  = true;
        
        self.contentMode = .scaleAspectFill;
        self.clipsToBounds = true;
    }
    
    @objc func pickImage() {
        guard let delegate = delegate else {
            return;
        }
        
        guard PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized else {
            if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.denied {
                delegate.showMessagePrompt(message: L10n.PickerImageView.deniedAccessToPhotos, customized: true);
                return;
            }
            
            PHPhotoLibrary.requestAuthorization { (phAuthorizationStatus) in
                if phAuthorizationStatus == PHAuthorizationStatus.authorized {
                    DispatchQueue.main.async {
                        self.pickImage();
                    }
                }
            }
            return;
        }
        
        if !UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            return;
        }
        
//        let imagePicker = UIImagePickerController();
//        imagePicker.delegate = self;
//        imagePicker.sourceType = .photoLibrary;
        
        let imagePicker = ProfileImagePickerViewController();
        imagePicker.imagePickerViewController.delegate = self;
        let navigationController = UINavigationController(rootViewController: imagePicker);
        navigationController.view.backgroundColor = ColorName.backgroundDark.color
        navigationController.modalPresentationStyle = .fullScreen;
        delegate.present(navigationController, animated: true);
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            picker.dismiss(animated: true, completion: nil);
            let cropViewController = useCircleCrop ? CropViewController(croppingStyle: .circular, image: pickedImage) : CropViewController(image: pickedImage);
            cropViewController.aspectRatioPickerButtonHidden = true;
            cropViewController.rotateButtonsHidden = true;
            cropViewController.resetAspectRatioEnabled = false;
            if let aspectRatio = aspectRatio {
                cropViewController.customAspectRatio = aspectRatio;
            }
            
            picker.dismiss(animated: false);
            
            cropViewController.delegate = self;
            cropViewController.modalPresentationStyle = .fullScreen;
            self.delegate?.present(cropViewController, animated: false);
        }
    }
}

extension PickerImageView: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true);
        self.image = image;
        self.isChanged = true;
          self.completionCallback?(self.image);
    }
}

extension PickerImageView: ImagePickerViewDelegate {
    func didSelect(controller: ImagePickerViewController) {
        controller.dismiss(animated: true);
        guard let phAsset = controller.selectedPHAssets.first else { return }
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.resizeMode = .fast
        requestOptions.isNetworkAccessAllowed = true //allow access to iCloud photos
        requestOptions.isSynchronous = false
                   
       var targetSize = PHImageManagerMaximumSize
       if phAsset.pixelWidth > 2048 || phAsset.pixelHeight > 2048 {
           targetSize = CGSize(width: 2048, height: 2048)
       }
        
        PHImageManager.default().requestImage(for: phAsset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions, resultHandler: { (image, error) in
            guard let image = image else {
                return;
            }
            
            self.showCropController(image: image);
        })
    }
    
    func showCropController(image: UIImage) {
        let cropViewController = useCircleCrop ? CropViewController(croppingStyle: .circular, image: image) : CropViewController(image: image);
        cropViewController.aspectRatioPickerButtonHidden = true;
        cropViewController.rotateButtonsHidden = true;
        cropViewController.resetAspectRatioEnabled = false;
        if let aspectRatio = aspectRatio {
            cropViewController.customAspectRatio = aspectRatio;
        }
        cropViewController.delegate = self;
        cropViewController.modalPresentationStyle = .fullScreen;
        delegate?.present(cropViewController, animated: false);
    }
}
