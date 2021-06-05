//
//  NewSpotLocationViewControllerUpdated.swift
//  Pao
//
//  Created by Waseem Ahmed on 23/10/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit
import Photos
import GooglePlaces

class NewSpotLocationViewControllerUpdated: BaseViewController, UISearchBarDelegate {
    
    var spot: Spot!
    var phAssets: [PHAsset] = []
    //var phAssetsDictionary = [String: PHAsset]()
    //var uploadImagesDictionary = [String:UIImage]()
    
    var searchBar = UISearchBar()
    let tableDataSource = GMSAutocompleteTableDataSource()
    private var tableView = ContentSizedTableView(frame: .zero, style: .plain)
    
    var cropDataList = [PHAsset:CropData]()
    
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
    
    private var keyboardHeight:CGFloat = 260
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Location Upload"
        
        title = L10n.NewSpotLocationViewController.title
        initialize()
        self.extendedLayoutIncludesOpaqueBars = true
        
//        DispatchQueue.global(qos: .background).async {
//            var spotMediaDictionary = SpotMediaDictionary()
//            let docDirectory: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//            self.phAssets.forEach { (phAsset) in
//                let spotMediaItem = SpotMediaItem()
//                spotMediaItem.id = DataContext.randomId
//                spotMediaItem.index = self.phAssets.firstIndex(of: phAsset)
//                spotMediaItem.type = phAsset.mediaType == .video ? 1 : 0
//                spotMediaItem.placeholderColor = "#ffffff"
//
//                phAsset.toFormData { (data, mime) in
//                    if let data = data {
//                        let fullUrl = docDirectory.appendingPathComponent("\(spotMediaItem.id!)")
//                        spotMediaItem.url = fullUrl
//                        if let asset = self.cropDataList[phAsset], let cropData = asset.cropedImage?.pngData() {
//                            try? cropData.write(to: fullUrl)
//                        } else {
//                            try? data.write(to: fullUrl)
//                        }
//                    }
//                }
//                // Prepare phAssetsDictionary and uploadImagesDictionary
//                self.phAssetsDictionary[spotMediaItem.id!] =  phAsset
//                if let asset = self.cropDataList[phAsset] {
//                    self.uploadImagesDictionary[spotMediaItem.id!] = asset.cropedImage
//                }
//                spotMediaDictionary[spotMediaItem.id!] = spotMediaItem
//            }
//            self.spot.isMediaServed = false
//            self.spot.timestamp = Date()
//            self.spot.mediaCount = spotMediaDictionary.count
//            self.spot.imagesCount = spotMediaDictionary.values.filter({$0.type == 0}).count
//            self.spot.videosCount = spotMediaDictionary.values.filter({$0.type == 1}).count
//            self.spot.media = spotMediaDictionary
//            self.spot.uploadStatus = SpotUploadStatus.preview.rawValue
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let name = spot.location?.name {
            searchBar.text = name
            tableDataSource.sourceTextHasChanged(name)
        }
        
        FirbaseAnalytics.trackScreen(name: .locationUpload)
        
        setInstructions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.searchBar.becomeFirstResponder()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.view.setNeedsLayout() // force update layout
        navigationController?.view.layoutIfNeeded() // to fix height of the navigation bar
    }
    
    func initialize() {
        tableView.frame = self.view.bounds.inset(by: UIEdgeInsets.init(top: 0, left: 0, bottom: keyboardHeight, right: 0))
        view.addSubview(tableView)
        
        setupGMSDatasource()
        setupSearchBar()
        
        tableView.dataSource = tableDataSource
        tableView.delegate = tableDataSource
        tableView.backgroundColor = ColorName.background.color
        tableView.tableFooterView = UIView(frame: .zero)
    }
    
    func setupGMSDatasource() {
        tableDataSource.primaryTextColor = ColorName.textWhite.color.withAlphaComponent(0.75)
        tableDataSource.secondaryTextColor = ColorName.textWhite.color.withAlphaComponent(0.4)
        tableDataSource.primaryTextHighlightColor = ColorName.textWhite.color
        tableDataSource.tableCellBackgroundColor = ColorName.background.color
        tableDataSource.tableCellSeparatorColor = ColorName.textWhite.color.withAlphaComponent(0.19)
        tableDataSource.tintColor = ColorName.textWhite.color
        tableDataSource.delegate = self
        
        let autocompleteFilter = GMSAutocompleteFilter()
        autocompleteFilter.type = .noFilter
        tableDataSource.autocompleteFilter = autocompleteFilter
    }
    
    func setupSearchBar() {
        searchBar.showsCancelButton = false
        searchBar.delegate = self
        searchBar.barStyle = .black
        searchBar.placeholder = L10n.Common.search
        navigationItem.titleView = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func set(location: Location) {
        spot.location = location
    }
    
    @objc func nextClicked(_ sender: UIBarButtonItem) {
        showNextController()
    }
    
    func showNextController() {
        FirbaseAnalytics.logEvent(.enterTip)
        AmplitudeAnalytics.logEvent(.uploadLocation, group: .upload)

        let viewController = NewSpotDescriptionViewController()
        viewController.spot = spot
        viewController.cropDataList = cropDataList
        viewController.phAssets = phAssets
        // viewController.phAssetsDictionary = phAssetsDictionary
        //viewController.uploadImagesDictionary = uploadImagesDictionary
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        tableDataSource.sourceTextHasChanged(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popToRootViewController(animated: true)
    }
}


extension NewSpotLocationViewControllerUpdated: GMSAutocompleteTableDataSourceDelegate {
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        if (place.types?.contains(where: {["establishment", "address", "route", "street_address", "premise"].contains($0)}) == false)
        {
            let message = L10n.NewSpotLocationViewController.locationIsTooGeneral
            self.showMessagePrompt(message: message, title: L10n.Common.Error.title, customized: true)
            //
            AmplitudeAnalytics.logEvent(.tooGeneralLocation, group: .uploadEvents, properties: ["error": message])
            searchBar.text = ""
            setInstructions()
            return
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
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        tableView.reloadData()
    }
    
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        tableView.reloadData()
        setInstructions()
    }
    
    private func setInstructions() {
        emptyView.removeFromSuperview()
        if tableView.numberOfRows(inSection: 0) <= 0, let text = searchBar.text ?? nil, text.isEmpty {
            tableView.addSubview(emptyView)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.emptyView.frame = tableView.bounds
    }
}


final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            print("\nContentSize: \(contentSize)")
            if contentSize.height > bounds.height + contentOffset.y {
                contentSize = CGSize.init(width: contentSize.width, height: bounds.height + contentOffset.y)
                invalidateIntrinsicContentSize()
            }
        }
    }
}

