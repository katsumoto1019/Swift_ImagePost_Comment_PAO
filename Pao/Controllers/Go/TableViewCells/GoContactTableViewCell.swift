//
//  GoToContactTableViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 04/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import MapKit

class GoContactTableViewCell: GoBaseTableViewCell {

    @IBOutlet weak var containerStackView: UIStackView!
    
    var spot: Spot?
    var placeDetails: PlaceDetailsResult?
    
    override func applyStyle() {
        
    }
    
    private func addButton(title: String,selector: Selector) {
        let button = GradientButton();
        
        button.setTitleColor(ColorName.textWhite.color, for: .normal)
        button.titleLabel?.font = UIFont.appMedium;
        button.makeCornerRound(cornerRadius: 3);
        button.widthAnchor.constraint(equalToConstant: 90).isActive = true;
        button.heightAnchor.constraint(equalToConstant: 35).isActive = true;

        button.setTitle(title, for: .normal);
        button.addTarget(self, action: selector, for: .touchUpInside);
        button.setGradient(topGradientColor: ColorName.gradientTop.color, bottomGradientColor: ColorName.gradientBottom.color)
        button.layer.opacity = 0.82;
        
        containerStackView.addArrangedSubview(button);
    }
    
    /// Actions
    @objc func openMap() {
        guard let coordinate = spot?.location?.coordinate?.clLocationCoordinate2D else {
            return;
        }
        
        if let spot = spot {
            FirbaseAnalytics.logEvent(.goDirections)
            let (category, subCategory) = spot.getCategorySubCategoryNameList()
            let postId = spot.id ?? ""
            let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
            AmplitudeAnalytics.logEvent(.directions, group: .spot, properties: properties)
            
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = spot.location?.name
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
    }
    
     @objc func openWebsite(_ sender: Any) {
        guard  let websiteString = placeDetails?.website else {
            return;
        }
        
        if let website = URL(string: websiteString) {
            FirbaseAnalytics.logEvent(.goWebsite)
            if let spot = spot {
                let (category, subCategory) = spot.getCategorySubCategoryNameList()
                let postId = spot.id ?? ""
                let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
                AmplitudeAnalytics.logEvent(.website, group: .spot, properties: properties)
            }
            UIApplication.shared.open(website);
        }
    }
    
     @objc func call(_ sender: UIButton) {
        guard  let phoneNumber = placeDetails?.formattedPhoneNumber else {
            return;
        }
        
        if let url = URL(string: String(format:"telprompt://%@", phoneNumber.replacingOccurrences(of: " ", with: ""))) {
            FirbaseAnalytics.logEvent(.goPhone)
            if let spot = spot {
                let (category, subCategory) = spot.getCategorySubCategoryNameList()
                let postId = spot.id ?? ""
                let properties = ["post ID": postId, "category": category, "subcategory": subCategory] as [String : Any]
                AmplitudeAnalytics.logEvent(.phone, group: .spot, properties: properties)
            }
            UIApplication.shared.open(url)
        }
    }
    
    override  func set(spot: Spot, placeDetails: PlaceDetailsResult?) {
        self.spot = spot;
        self.placeDetails = placeDetails;
        
        for arrangedSubview in containerStackView.arrangedSubviews {
            containerStackView.removeArrangedSubview(arrangedSubview);
            arrangedSubview.removeFromSuperview();
        }
        
        if placeDetails?.website != nil {
            addButton(title: L10n.GoContactTableViewCell.website, selector: #selector(openWebsite(_:)));
        }
        
        if spot.location?.coordinate?.clLocationCoordinate2D != nil {
            addButton(title: L10n.GoContactTableViewCell.directions, selector: #selector(openMap));
        }
        
        if placeDetails?.formattedPhoneNumber != nil {
            addButton(title: L10n.GoContactTableViewCell.phone, selector: #selector(call(_:)));
        }
    }
}
