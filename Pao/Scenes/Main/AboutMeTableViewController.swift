//
//  AboutMeTableViewController.swift
//  Pao
//
//  Created by Exelia Technologies on 05/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import Foundation
import GooglePlaces
import Payload

import RocketData

class AboutMeTableViewController: StyledTableViewController {
    
    var gmsLocationType:AboutMeLocationType?
    
    private var user: User!
    private let dataProvider = DataProvider<User>()
    
    var isCurrentUser: Bool {
        return self.user.id == DataContext.cache.user?.id
    }
    
    init(user: User) {
        super.init(style: .grouped)
        
        self.user = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        dataProvider.fetchDataFromCache(withCacheKey: user.modelIdentifier) { (user, error) in
            self.user = user
            self.tableView.reloadData()
        }
        
        dataProvider.delegate = self
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
    }
    
    private func setupTableView() {
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(AboutMeStatsTableViewCell.self)
        tableView.register(AboutMeBioTableViewCell.self)
        tableView.register(AboutMeLocationTableViewCell.self)
        tableView.register(EditProfileTagsTableViewCell.self)
        tableView.register(EditProfileAddTagsTableViewCell.self)
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
        
        FirbaseAnalytics.trackScreen(name: .locationAboutMe, screenClass: String(describing: self))
        
        autocompleteController.modalPresentationStyle = .fullScreen
        present(autocompleteController, animated: true, completion: nil)
    }
    
    func updateCounters(user: User) {
        self.user = user
        self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 0)], with: .fade)
    }
}

// MARK: - AboutMeLocationTableViewCellDelegate
extension AboutMeTableViewController: AboutMeLocationTableViewCellDelegate {
    func aboutMeLocationCell(_ cell: AboutMeLocationTableViewCell, showGooglePlaceforLocation locationType: AboutMeLocationType) {
        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : locationType.rawValue])
        
        gmsLocationType = locationType
        self.showGooglePlacesController()
    }
    
    func deleteLocation(_ cell: AboutMeLocationTableViewCell, deleteLocationfor locationType: AboutMeLocationType) {
        FirbaseAnalytics.logEvent(locationType == AboutMeLocationType.currently ?
            .editCurrently : locationType == AboutMeLocationType.next ?
                .editNextStop : .editHomeTown)
        
        updateAddress(location: nil , type: locationType)
    }
}

// MARK: - TableView Delegate and DataSource
extension AboutMeTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        if user.id == nil { return 0 }
        if isCurrentUser { return 4 }
        
        var count = 1
        if !(user.bio?.isEmpty ?? true) { count = count + 1 }
        if let profile = user.profile, (!(profile.currentLocation?.isEmpty ?? true) || !(profile.nextStop?.isEmpty ?? true) || !(profile.hometown?.isEmpty ?? true)) {
            count = count + 1
        }
        if let interests = user.profile?.interests, interests.count > 0 { count = count + 1 }
        return count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let resolvedSection = isCurrentUser ? indexPath.section : resolveSection(section: indexPath.section)
        
        switch resolvedSection {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutMeStatsTableViewCell.reuseIdentifier) as! AboutMeStatsTableViewCell
            cell.isSelfUser = user.id == DataContext.cache.user.id
            cell.set(numOfYourPeople: user.myPeopleCount ?? 0, numOfCities: user.citiesCount ?? 0, numOfCountries: user.countriesCount ?? 0)
            cell.clickCallback = { index in
                self.showCounters(index: index)
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutMeBioTableViewCell.reuseIdentifier) as! AboutMeBioTableViewCell
            cell.set(bio: user.bio ?? "",bioChanged: {_ in})
            cell.bioChangeEnded =  {text in
                AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "bio"])
                
                self.user.bio = text
                self.post(user:self.user)
            }
            cell.isUserInteractionEnabled = isCurrentUser
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutMeLocationTableViewCell.reuseIdentifier) as! AboutMeLocationTableViewCell
            cell.delegate = self
            cell.set(hometown: user.profile?.hometown, currently: user.profile?.currentLocation, nextStop: user.profile?.nextStop, isCurrentuser: self.isCurrentUser)
            cell.isUserInteractionEnabled = isCurrentUser
            return cell
        case 3:
            if ((user.profile?.interests?.count ?? 0) > 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileTagsTableViewCell.reuseIdentifier, for: indexPath) as! EditProfileTagsTableViewCell
                cell.set(tags: user.profile?.interests ?? [], isCurrentUser: isCurrentUser, plusButtonTouchedInside: plusButtonTouchedInside)
                cell.isUserInteractionEnabled = isCurrentUser
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileAddTagsTableViewCell.reuseIdentifier, for: indexPath) as! EditProfileAddTagsTableViewCell
                cell.set(plusButtonTouchedInside: plusButtonTouchedInside)
                cell.isUserInteractionEnabled = isCurrentUser
                return cell
            }
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let resolvedSection = isCurrentUser ? section : resolveSection(section: section)
        
        switch (resolvedSection) {
        case 0: return nil
        case 1:
            guard let name = user?.name , name.split(separator: " ").count > 0 else {
                return "\(L10n.AboutMeTableViewController.meetLabel):"
            }
            return String(format: "\(L10n.AboutMeTableViewController.meetLabel) %@:", String(name.split(separator: " ").first!).trim.capitalizingFirstLetter)
        case 2: return isCurrentUser ? "\(L10n.AboutMeTableViewController.whereYoureAt):" : "\(L10n.AboutMeTableViewController.whereTheyreAt):"
        case 3: return isCurrentUser ? "\(L10n.AboutMeTableViewController.whatYoureInto):" : "\(L10n.AboutMeTableViewController.whatTheyreInto):"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) else {
            return nil
        }
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 20))
        let headerViewLabel = UILabel.init(frame: CGRect.init(x: 16, y: 0, width: tableView.bounds.width, height: 16))
        headerViewLabel.tintColor = ColorName.background.color
        headerViewLabel.textColor = ColorName.accent.color
        headerViewLabel.font =  UIFont.appNormal.withSize(UIFont.sizes.small)
        
        headerViewLabel.text = title
        headerView.addSubview(headerViewLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0: return 50
        default: return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        let resolvedSection = isCurrentUser ? indexPath.section : resolveSection(section: indexPath.section)
        switch (resolvedSection) {
        case 1: return 30
        case 2: return 60
        case 3: return 20
        default: return 10
        }
    }
    
    private func plusButtonTouchedInside() {
        FirbaseAnalytics.logEvent(.profileTags)
        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "tags"])
        
        let editTagsViewController = ProfileEditTagsViewController(tags: user.profile?.interests ?? [], tagsUpdated: { tags in
            
            if self.user.profile == nil {
                self.user.profile = UserProfile()
            }
            self.user.profile?.interests = tags.map({$0 as! String})
            self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 3)], with: .automatic)
            self.post(profile:self.user.profile!)
        })
        
        let navigationController = UINavigationController(rootViewController: editTagsViewController)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
    }
    
    @objc func cancelEdit() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    private func updateAddress(location: Location?, type: AboutMeLocationType) {
        var text = ""
        if let location = location{
            let city = (location.city != nil ? location.city! : location.state)
            text = "\(city ?? "") \(location.country ?? "")".trim
            
            if  let country = location.country {
                let format = "%@, %@"
                text = String(format: "%@ %@", city != nil ? city! + "," : "", country).trim
                if (country.caseInsensitiveCompare("United States") == .orderedSame) {
                    if let city = location.city, let state = location.state {
                        text = String(format: format, city, state)
                    }
                }
            }
        }
        
        if user.profile == nil {
            user.profile = UserProfile()
        }
        
        switch type {
        case .hometown: user.profile?.hometown = text
        case .currently: user.profile?.currentLocation = text
        case .next: user.profile?.nextStop = text
        }
        
        FirbaseAnalytics.logEvent(type == AboutMeLocationType.currently ?
            .editCurrently : type == AboutMeLocationType.next ?
                .editNextStop : .editHomeTown)
        
        post(profile:self.user.profile!)
        tableView.reloadRows(at: [IndexPath.init(row: 0, section: 2)], with: .automatic)
    }
}

//Mark - TableView Helper functions
extension AboutMeTableViewController {
    func resolveSection(section: Int) -> Int {
        switch (section) {
        case 0,3:
            return section
        case 1:
            if !(user.bio?.isEmpty ?? true) {
                return section
            }
            if let profile = user.profile, (!(profile.currentLocation?.isEmpty ?? true) || !(profile.hometown?.isEmpty ?? true) || !(profile.nextStop?.isEmpty ?? true)) {
                return 2
            }
            return 3
        case 2:
            if let profile = user.profile, (!(profile.currentLocation?.isEmpty ?? true) || !(profile.nextStop?.isEmpty ?? true) || !(profile.hometown?.isEmpty ?? true)) {
                if resolveSection(section: 1) != 1 { return 3 }
                return section
            }
            return 3
        default:
            return section
        }
    }
}


// MARK: - GMSAutocompleteViewControllerDelegate
extension AboutMeTableViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        let location = Location()
        
        location.gmsAddress = place.addressComponents?.reduce([String: String](), { (result, gmsAddressComponent) -> [String: String] in
            var result = result
            
            if let type = gmsAddressComponent.types.first {
                result[type] = gmsAddressComponent.name
            }
            
            return result
        })
        
        updateAddress(location: location, type: gmsLocationType!)
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        viewController.dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}


extension AboutMeTableViewController {
    func post(user: User) {
        App.transporter.post(user) { _ in }
    }
    
    func post(profile: UserProfile) {
        App.transporter.post(profile) { _ in }
    }
}

extension AboutMeTableViewController {
    
    func showCounters(index: Int) {
        FirbaseAnalytics.logEvent(index == 1 ? .howManyCities : index == 2 ? .howManyCountries : .howManyFriends)
        AmplitudeAnalytics.logEvent(index == 1 ? .myCities : index == 2 ? .myCountries : .myFriends, group: .myProfile)
        
        guard let user = user, let userId = user.id else {return}
        
        let viewController = ProfileCounterViewController(userId: userId, tabIndex: index, userObject : self.user)
        viewController.modalPresentationStyle = .custom
        viewController.transitioningDelegate = self
        
        self.present(viewController, animated: true) {
            (viewController.viewControllers[0] as? FollowingsTableViewController)?.showProfile = {userInList in
                if let navController = self.navigationController {
                    navController.setNavigationBarHiddenWithCustomAnimation(true, animated: true)
                    let viewController = UserProfileViewController(user: userInList)
                    viewController.isNavigationBarHiddenOnParent = navController.navigationBar.isHidden
                    navController.pushViewController(viewController, animated: true)
                }
            }
        }
    }
}

extension AboutMeTableViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = PullUpPresentationController(presentedViewController: presented, presenting: presenting)
        if let heightPrecent: CGFloat = [ProfileCounterViewController.typeName: 0.5][String(describing: type(of: presented))] {
            controller.heightPercent = heightPrecent
        }
        
        controller.onDismiss = {
            if #available(iOS 13.0, *) {}
            else {
                UIApplication.shared.statusBarView?.backgroundColor = .clear
            }
            
            let name: ScreenNames = self.isCurrentUser ? .myProfileAbout : .othersProfileAbout
            
            FirbaseAnalytics.trackScreen(name: name, screenClass: String(describing: self))
        }
        return controller
    }
}

extension AboutMeTableViewController: DataProviderDelegate {
    func dataProviderHasUpdatedData<T>(_ dataProvider: DataProvider<T>, context: Any?) where T : SimpleModel {
        user = self.dataProvider.data
        tableView.reloadData()
    }
}
