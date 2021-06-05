//
//  NewSpotLocationViewController.swift
//  Pao
//
//  Created by Developer on 2/22/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Photos
import GooglePlaces

class NewSpotLocationViewController: BaseViewController {
    
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    var spot: Spot!
    var phAssets: [PHAsset] = []
    
    private var emptyView:UIView = {
        var stackView = UIStackView()
        stackView.axis = .vertical
        stackView.backgroundColor = UIColor.clear
        stackView.spacing = 8.0
        
        stackView.addArrangedSubview(UILabel.init(text: L10n.NewSpotLocationViewController.searchForSpotsLocation, font: UIFont.app.withSize(UIFont.sizes.normal), color: .white, textAlignment: .center))
        stackView.addArrangedSubview(UILabel.init(text: L10n.NewSpotLocationViewController.beSpecific, font: UIFont.app.withSize(UIFont.sizes.small), color: .lightGray, textAlignment: .center))
        stackView.arrangedSubviews.forEach({ $0.translatesAutoresizingMaskIntoConstraints = false })
        
        var containerView = UIView()
        containerView.backgroundColor = .clear
        containerView.addSubview(stackView)
        stackView.constraintToFitInCenter(inContainerView: containerView)
        stackView.constraintToFitHorizontally(inContainerView: containerView)
        
        return containerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Location Upload"
        
        title = L10n.NewSpotLocationViewController.title
        initialize()
        
        if spot.location == nil {
            showGooglePlacesController()
        }
    }
    
    private func initialize() {
        setupNavBar()
        setupLocation()
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        headingLabel.textColor = ColorName.textWhite.color
        headingLabel.set(fontSize: UIFont.sizes.large)
    }
    
    private func setupLocation() {
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action: #selector(showGooglePlacesController))
        locationLabel.addGestureRecognizer(tapGestureRecognizer)
        locationLabel.isUserInteractionEnabled = true
        locationLabel.set(fontSize: UIFont.sizes.normal)
        
        if let location = spot.location {
            set(location: location)
        } else {
            locationLabel.text = L10n.NewSpotLocationViewController.addPlace
        }
    }
    
    private func setupNavBar() {
        let nextBarButton = UIBarButtonItem(title: L10n.Common.NextButton.text, style: .done, target: self, action: #selector(nextClicked))
        nextBarButton.isEnabled = false
        self.navigationItem.rightBarButtonItem = nextBarButton
    }
    
    @objc func nextClicked(_ sender: UIBarButtonItem) {
        showNextController()
    }
    
    func showNextController() {
        FirbaseAnalytics.logEvent(.enterTip)

        let viewController = NewSpotDescriptionViewController()
        viewController.spot = spot
        viewController.phAssets = phAssets
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    @objc func showGooglePlacesController() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.primaryTextColor = ColorName.textWhite.color.withAlphaComponent(0.75)
        autocompleteController.secondaryTextColor = ColorName.textWhite.color.withAlphaComponent(0.4)
        autocompleteController.primaryTextHighlightColor = ColorName.textWhite.color
        autocompleteController.tableCellBackgroundColor = ColorName.background.color
        autocompleteController.tableCellSeparatorColor = ColorName.textWhite.color.withAlphaComponent(0.19)
        autocompleteController.tintColor = ColorName.textWhite.color
        autocompleteController.delegate = self
        
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .noFilter
        autocompleteController.autocompleteFilter = autocompleteFilter
        
        FirbaseAnalytics.trackScreen(name: .locationUpload)
        
        autocompleteController.modalPresentationStyle = .fullScreen
        present(autocompleteController, animated: false) {
            self.setInstructions(viewController: autocompleteController)
        }
    }
    
    private func set(location: Location) {
        spot.location = location
        let name = (location.name != nil) ? location.name! + ", " : String.empty
        let formattedAddress = location.formattedAddress ?? String.empty
        locationLabel.text = name + formattedAddress
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension NewSpotLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}


extension NewSpotLocationViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        if (place.types?.contains(where: {["establishment", "address", "route", "street_address", "premise"].contains($0)}) == false)
        {
            viewController.showMessagePrompt(message: L10n.NewSpotLocationViewController.locationIsTooGeneral, title: L10n.Common.Error.title, customized: true)
            let views = viewController.view.subviews
            let subviewsOfSubview = views.first!.subviews
            let subOfNavTransitionView = subviewsOfSubview[1].subviews
            
            if #available(iOS 13.0, *) {
                let subOfContentView = subOfNavTransitionView[1].subviews
                let searchBar = subOfContentView[0] as! UISearchBar
                searchBar.text = ""
            } else {
                let subOfContentView = subOfNavTransitionView[2].subviews
                let searchBar = subOfContentView[0] as! UISearchBar
                searchBar.text = ""
            }
            return;
        }
                
        let location = Location()
        location.name = place.name
        location.googlePlaceId = place.placeID
        location.formattedAddress = place.formattedAddress
        location.types = place.types?.map({(type:String) -> String in
            //            return type.replacingOccurrences(of:"_", with: " ").capitalizingFirstLetter;
            return type
        })
        
        
        let coordinate = Coordinate();
        coordinate.latitude = place.coordinate.latitude
        coordinate.longitude = place.coordinate.longitude
        location.coordinate = coordinate
        
        location.gmsAddress = place.addressComponents?.reduce([String: String](), { (result, gmsAddressComponent) -> [String: String] in
            var result = result
			
            if let type = gmsAddressComponent.types.first {
				result[type] = gmsAddressComponent.name
			}
			
            return result
        });
        
        set(location: location)
        
        showNextController()
        
        viewController.dismiss(animated: false, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
                
        setInstructions(viewController: viewController)
    }
    
    private func setInstructions(viewController: UIViewController) {
        if  let tableView = viewController.view.findSubView(ofType: UITableView.self) {
                emptyView.removeFromSuperview()
                if tableView.numberOfRows(inSection: 0) <= 0 && tableView.numberOfRows(inSection: 2) == 1 {
                    tableView.addSubview(emptyView)
                    emptyView.frame = CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height - 260.0) // 260 is for keyboard height
                }
            }
    }
}
