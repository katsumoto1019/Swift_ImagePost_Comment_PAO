//
//  GoViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 03/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import MapKit
import Payload

import RocketData

class GoViewController: BaseViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var subTitle2Label: UILabel!
    @IBOutlet private var mapView: MKMapView!
    @IBOutlet private var saveButton: UIButton!
    @IBOutlet private var tableView: UITableView!
    @IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
    // MARK: - Private properties
    
    private var spot: Spot!
    private var mapShadowLayer: CALayer?
    private var placeDetails: PlaceDetailsResult?
    private lazy var dataProvider = DataProvider<Spot>()
    private lazy var goPhotosCollectionViewController = GoPhotosCollectionViewController(spot: spot)
    
    // MARK: - Internal properties
    
    var selectBookmarkCallBack: ((_ updatedSpot: Spot)-> Void)?
    
    // MARK: - Lifecycle
    
    init(spot: Spot) {
        super.init(nibName: nil, bundle: nil)
        
        self.spot = spot
        dataProvider.setCacheKey(spot.modelIdentifier!)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Go Screen"
        
        setupChildControllers()
        styleLabels()
        initLabels()
        addMapAnnotation()
        tableHeightConstraint.constant = 250
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mapShadowLayer?.removeFromSuperlayer()
        mapShadowLayer = mapView.addInnerShadow(radius: 10, opecity: 1.0, frame: CGRect.init(origin: CGPoint.zero, size: CGSize(width: self.view.bounds.width - 16, height: mapView.bounds.height)))
        
        self.tableHeightConstraint.constant = self.tableView.contentSize.height
    }
    
    // MARK: - Actions
    
    @IBAction private func action(_ sender: UIButton) {
        
        let action: SpotAction = sender.isSelected ? .unsave : .save
        
        FirbaseAnalytics.logEvent(action == .save ? .clickSaveIcon : .clickUnSaveIcon)
        AmplitudeAnalytics.logEvent(.saveOnGoPage, group: .spot, properties: ["save": action == .save ? "save" : "unsave"])
        
        spot.isSavedByViewer = action == .save
        spot.saves! += action == .save ? 1 : -1
        update()
        
        sender.isSelected = spot.isSavedByViewer == true
        
        let spotToSave = Spot()
        spotToSave.id = spot.id
        
        App.transporter.post(spotToSave, to: action) { (success) in
            if success == true {
                NotificationCenter.spotSaved()
            } else {
                self.spot.isSavedByViewer = action == .unsave
                self.spot.saves! += action == .unsave ? 1 : -1
                self.update()
                
                sender.isSelected = self.spot.isSavedByViewer == true
            }
        }
    }
    
    @IBAction func btnMap_Tapped(_ sender: Any) {
        let fullScreenMapViewController = FullScreenMapViewController()
        fullScreenMapViewController.location = spot.location
        fullScreenMapViewController.title = spot.location?.cityFormatted
        let navigationController = UINavigationController.init(rootViewController: fullScreenMapViewController)
        self.present(navigationController, animated: true, completion: nil)
        fullScreenMapViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(goBack)
        )
    }
    
    @objc func goBack() {
        presentedViewController?.dismiss(animated: true, completion: nil);
    }
    
    // MARK: - Private methods
    
    private func styleLabels() {
        titleLabel.textColor = ColorName.accent.color
        subTitleLabel.textColor = ColorName.textWhite.color
        subTitle2Label.textColor = ColorName.textGray.color
        
        titleLabel.font = UIFont.appHeavy.withSize(UIFont.sizes.normal)
        subTitleLabel.set(fontSize: UIFont.sizes.verySmall)
        subTitle2Label.set(fontSize: UIFont.sizes.verySmall)
        
        saveButton.imageView?.contentMode = .scaleAspectFill
        saveButton.imageView?.frame = saveButton.bounds
    }
    
    private func initLabels() {
        saveButton.isSelected = spot.isSavedByViewer == true
        saveButton.isEnabled = !spot.isUserSpot
        
        titleLabel.text = spot.location?.name
        subTitleLabel.text = spot?.location?.cityFormatted
        subTitle2Label.text = spot?.location?.typeFormatted
    }
    
    private func setupChildControllers() {
        containerView.clipsToBounds = true
        setupTableView()
        addChild(goPhotosCollectionViewController)
        containerView.addSubview(goPhotosCollectionViewController.view)
        goPhotosCollectionViewController.didMove(toParent: self)
        getPlaceInfo()
        getPlaceDescription()
        
        goPhotosCollectionViewController.spotDidUpdateCallBack = { (spot: Spot) in
            self.spot = spot
            self.initLabels()
            self.update()
        }
    }
    
    private func addMapAnnotation() {
        guard
            let latitude = spot.location?.coordinate?.latitude,
            let longitude = spot.location?.coordinate?.longitude else { return }
        
        let anotation = MKPointAnnotation()
        anotation.title = spot.location?.city
        anotation.subtitle = spot.location?.country
        anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        mapView.delegate = self
        mapView.addAnnotation(anotation)
        mapView.centerCoordinate = anotation.coordinate
        mapView.zoomToLocation(Coordinate: anotation.coordinate)
    }
    
    private func update() {
        selectBookmarkCallBack?(spot)
        let data = dataProvider.data
        data?.isSavedByViewer = spot.isSavedByViewer
        data?.saves = spot.saves
        dataProvider.setData(data)
    }
    
    //MARK: - GoSpotInfo TableView
    private func setupTableView() {
        tableView.separatorStyle = .none;
        tableView.register(GoAboutTableViewCell.self);
        tableView.register(GoFactsTableViewCell.self);
        tableView.register(GoContactTableViewCell.self);
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func getPlaceInfo() {
        guard let placeId = spot.location?.googlePlaceId else { return; }
        let placeDetails: [PlaceDetail] = [.openingHours,
                                           .formattedPhoneNumber,
                                           .formattedAddress,
                                           .website,
                                           .businessStatus];
        
        APIContext.shared.getPlaceDetails(placeDetails,
                                          placeId: placeId,
                                          inLanguage: .english) { (data, urlResponse, error) in
            guard let details = try? data?.convert(PlaceDetailsResponse.self).result else { return; }
            self.placeDetails = details
            self.tableView.reloadData();
        }
    }
    
    private func getPlaceDescription() {
        guard let name = spot.location?.name, spot.location?.about == nil else {return}
        APIContext.shared.placeDescription(searchTerm: name) { (responseData, response, error) in
            if let kgResult = try? responseData?.convert(KGResult.self) {
                self.spot.location?.about = kgResult.itemListElement?[safe: 0]?.result?.detailedDescription?.articleBody;
                self.tableView.reloadData();
            }
        }
    }
}

extension GoViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        var section = 1
        section += (placeDetails != nil) ? 1: 0
        return section
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = GoContactTableViewCell.reuseIdentifier;
        switch indexPath.section {
        case 0:
            identifier = placeDetails != nil ? GoFactsTableViewCell.reuseIdentifier : identifier;
            break;
        case 1:
            break;
        default:
            identifier = GoContactTableViewCell.reuseIdentifier;
            break;
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! GoBaseTableViewCell
        cell.set(spot: spot, placeDetails: placeDetails);
        return cell
    }
}

extension GoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        headerView.text = ""
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
         return 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return section == 0 ? 16 : 10
    }
    
    func titleForHeader(inSection section: Int)-> String? {
        return nil
    }
}

extension GoViewController: PullUpPresentationControllerDelegate {
    var canDismiss: Bool {
        return true
    }
}

// MARK: - MapkitViewDelegate implementation

extension GoViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "Annotation"
        
        guard annotation is MKPointAnnotation else { return nil }
        guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.canShowCallout = true
            return annotationView
        }
        
        annotationView.annotation = annotation
        return annotationView
    }
}

// MARK: - Mapkit extension for zoomimg function

fileprivate extension MKMapView {
    
    func zoomToLocation(Coordinate coordinate: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        setRegion(region, animated: true)
    }
}
