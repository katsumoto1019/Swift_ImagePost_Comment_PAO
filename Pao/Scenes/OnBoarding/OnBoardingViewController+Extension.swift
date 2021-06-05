//
//  OnBoardingViewController+Extension.swift
//  Pao
//
//  Created by Waseem Ahmed on 20/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

//First OnBoarding screen
extension OnBoardingViewController {
    class func readSpots() -> [Spot] {
        //read json file as asset
        var finalSpots = [Spot]()
        let asset = NSDataAsset(name: "Spots", bundle: Bundle.main)
        let json = try? JSONSerialization.jsonObject(with: asset!.data, options: JSONSerialization.ReadingOptions.allowFragments)
        if let jsonResult = json as? Dictionary<String, AnyObject>, let spots = jsonResult["spots"] as? [Any] {
            
            spots.forEach {
                if let spot = $0 as? [String:Any] {
                    if let jsonData = try? JSONSerialization.data(withJSONObject: spot, options: []),
                        let dataObject = try? JSONDecoder().decode(Spot.self, from: jsonData) {
                        
                        dataObject.user?.profileImage!.url = self.createLocalUrl(forImageNamed:  (dataObject.user?.profileImage!.url?.absoluteString)!)
                        
                        dataObject.media?.keys.forEach { (key) in
                            dataObject.media![key]?.url = self.createLocalUrl(forImageNamed: (dataObject.media![key]?.url?.absoluteString)!)
                        }
                        
                        finalSpots.append(dataObject)
                    }
                }
            }
        }
        return finalSpots
    }
    
    func setupSpotViewController() {
        //add profileView to screen
        let baordingSpotViewController = OnBoardingSpotsViewController(spots: spots)
        baordingSpotViewController.view.isUserInteractionEnabled = false
        
        var bottomSpacing:CGFloat = -10.0
        
        if (UIScreen.main.bounds.height > 736.0) {
            bottomSpacing = 70.0
        }
        
        self.addChild(baordingSpotViewController)
        innerContainerView.addSubview(baordingSpotViewController.view)
        baordingSpotViewController.view.constraintToFit(inContainerView: innerContainerView, inset: UIEdgeInsets.init(top: -50, left: 0, bottom: bottomSpacing, right: 0))
        baordingSpotViewController.didMove(toParent: self)
    }
    
    func addFrame() {
        let imageView = UIImageView(image: Asset.Boarding.Frame.frame.image)
        innerContainerView.addSubview(imageView)
        imageView.constraintToFit(inContainerView: innerContainerView)
    }
    
}


//Second OnBoarding screen
extension OnBoardingViewController {
    
    class func createLocalUrl(forImageNamed name: String) -> URL? {
        guard let directory = try? FileManager.default.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL, let url = directory.appendingPathComponent("\(name).png") else {
            return nil
        }
        
        guard let image = UIImage(named: name), let data = image.jpegData(compressionQuality: 0.75) ?? image.pngData() else {
            return nil
        }
        do { try data.write(to: url)
            return url
        } catch {  return nil }
    }
}
