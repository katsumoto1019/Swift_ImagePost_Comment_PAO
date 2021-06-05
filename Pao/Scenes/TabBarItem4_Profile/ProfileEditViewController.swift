//
//  ProfileEditViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/21/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase
import GooglePlaces
import Payload

import Kingfisher
import RocketData

class ProfileEditViewController: StyledTableViewController {
    var isLoading = false
    var user = User()
    var username: String?
    private var taskGroup = DispatchGroup()
    
    //used to temporarily store changed images
    private var coverImage:UIImage?
    private var profileImage: UIImage?
    
    //Used to deferentiate in LocationTypes
    private var gmsLocationType:AboutMeLocationType?
    
    var task: URLSessionTask?
    
    private var hasTags: Bool {
        return ((user.profile?.interests?.count ?? 0) > 0)
    }
    
    init() {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        screenName = "Edit Profile"
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        setupTableView()
        setupNavigationBar()
        user = DataContext.cache.user
        
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.backgroundColor = ColorName.navigationBarTint.color
    }
    
    private func setupTableView() {
        tableView.register(EditProfileTagsTableViewCell.self)
        tableView.register(EditProfileAddTagsTableViewCell.self)
        tableView.register(AboutMeInfoTableViewCell.self)
        tableView.register(ProfileImageViewCell.self)
        tableView.register(AboutMeLocationTableViewCell.self)
        tableView.register(AboutMeBioTableViewCell.self)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
    }
    
    func setupNavigationBar() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: L10n.Common.done, style: .done, target: self, action: #selector(doneEditing))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        title = L10n.ProfileEditViewController.title
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        title = ""
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // TODO: Refactor this
    @objc func doneEditing() {
        if (username?.count ?? 10 < 2) {
            showMessagePrompt(message: L10n.ProfileEditViewController.editingError)
            return
        }
        
        let activityIndicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        activityIndicator.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        user.username = username
        
        self.save()
    }
    
    private func save() {        
        print(user)
        
        let url = App.transporter.getUrl(User.self, httpMethod: .post)
        var request = URLRequest(url: url)
        
        let boundary = UUID().uuidString
        request.addValue(String(format: "multipart/form-data; boundary=%@", boundary), forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = HttpMethod.post.rawValue
        
        if coverImage != nil {
            let fileName = UUID().uuidString
            self.user.coverImage!.url = URL(string: fileName)
            self.user.coverImage!.id = fileName
        }
        
        if profileImage != nil {
            let fileName = UUID().uuidString
            self.user.profileImage!.url = URL(string: fileName)
            self.user.profileImage!.id = fileName
        }
        
        createMultipartBody(formJson: String(bytes: try! user.toData(), encoding: String.Encoding.utf8)!, boundary: boundary) { (data) in
            request.httpBody = data
            self.task = App.transporter.executeRequest(request) { (result: User?) in
                if result != nil {
                    
                    self.user.profileImage!.url = result?.profileImage?.url
                    self.user.coverImage!.url = result?.coverImage?.url
                    
                    DataContext.cache.loadUser()
                    if let profileImage = self.profileImage {
                        NotificationCenter.default.post(name: .profileImageUpdate, object: profileImage)
                    }
                }
                
                if result != nil, let username = self.username, result?.username != username {
                    self.showMessagePrompt(message: L10n.ProfileEditViewController.usernameTakenError, title: "", action: L10n.Common.gotIt, handler: { (action) in
                        self.navigationController?.popViewController(animated: true)
                    })
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // create multipart object
    func createMultipartBody(formJson: String, boundary: String, completion: @escaping (Data?) -> Void)
    {
        var body = Data()
        
        //boundary
        body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition: form-data; name=\"user\"\r\n".data(using: String.Encoding.utf8)!)
        body.append(String(format:"Content-Type: application/json\r\n\r\n").data(using: String.Encoding.utf8)!)
        body.append(formJson.data(using: String.Encoding.utf8)!)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        
        taskGroup.enter()
        
        if let image = coverImage, let imageData = image.jpegData(compressionQuality: 0.75) {
            body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
            body.append(String(format:"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", user.coverImage!.id!, user.coverImage!.id!).data(using: String.Encoding.utf8)!)
            body.append(String(format:"Content-Type: %@\r\n\r\n", "image/jpg").data(using: String.Encoding.utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        
        if let image = profileImage, let imageData = image.jpegData(compressionQuality: 0.75)  {
            body.append(String(format:"--%@\r\n", boundary).data(using: String.Encoding.utf8)!)
            body.append(String(format:"Content-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\n", user.profileImage!.id!, user.profileImage!.id!).data(using: String.Encoding.utf8)!)
            body.append(String(format:"Content-Type: %@\r\n\r\n", "image/jpg").data(using: String.Encoding.utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: String.Encoding.utf8)!)
        }
        body.append(String(format:"--%@--", boundary).data(using: String.Encoding.utf8)!)
        completion(body)
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
        
        FirbaseAnalytics.trackScreen(name: .locationEditProfile)
        
        autocompleteController.modalPresentationStyle = .fullScreen
        present(autocompleteController, animated: true, completion: nil)
        // view.superview?.parentContainerViewController()?.present(autocompleteController, animated: true, completion: nil)
    }
    
    private func updateAddress(location: Location, type: AboutMeLocationType) {
        var text = "\(location.city ?? "") \(location.country ?? "")".trim
        
        if  let country = location.country {
            let format = "%@, %@"
            text = String(format: "%@ %@", location.city != nil ? location.city! + "," : "", country).trim
            
            if (country.caseInsensitiveCompare("United States") == .orderedSame) {
                if let city = location.city, let state = location.state {
                    text = String(format: format, city, state)
                }
            }
        }
        if user.profile == nil {
            user.profile = UserProfile()
        }
        
        var action = EventAction.editHomeTown
        switch type {
        case .hometown:
            user.profile?.hometown = text
        case .currently:
            user.profile?.currentLocation = text
            action = .editCurrently
        case .next:
            user.profile?.nextStop = text
            action = .editNextStop
        }
        
        FirbaseAnalytics.logEvent(action)
        
        tableView.reloadRows(at: [IndexPath.init(row: 0, section: 3)], with: .automatic)
    }
}


// MARK: - Tabelview wxtensiosn
extension ProfileEditViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch (indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfileImageViewCell.reuseIdentifier, for: indexPath) as! ProfileImageViewCell
            cell.set(coverImageUrl: user.coverImage?.url, profileImageUrl: user.profileImage?.url)
            cell.delegate = self
            cell.coverImageView.completionCallback = { image in
                self.coverImage = image
                AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "cover photo"])
            }
            cell.profileImageView.completionCallback = { image in
                self.profileImage = image
                AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "round photo"])
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutMeInfoTableViewCell.reuseIdentifier, for: indexPath) as! AboutMeInfoTableViewCell
            cell.set(topKey: "Name", topValue: user.name, topValuePlaceholder: nil, topKeyboardType: .namePhonePad,
                     topValueChanged: { (name) in
                        self.user.name = name?.capitalized
                        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "name"])
            },
                     
                     middleKey: "Username", middleValue: user.username, middleValuePlaceholder: nil, middleKeyboardType: .namePhonePad,
                     middleValueChanged: { (username) in
                        self.username = username?.toUsername()
                        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "username"])
            },
                     
                     bottomKey: "Email", bottomValue: self.user.email, bottomValuePlaceholder: nil, bottomKeyboardType: .emailAddress,
                     bottomValueChanged: { (email) in
                        self.user.email = email
                        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "email"])
            })
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutMeBioTableViewCell.reuseIdentifier) as! AboutMeBioTableViewCell
            cell.set(bio: user.bio ?? "", bioChanged: {text in
                self.user.bio = text
                AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "bio"])
            })
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: AboutMeLocationTableViewCell.reuseIdentifier) as! AboutMeLocationTableViewCell
            cell.delegate = self
            cell.set(hometown: user.profile?.hometown, currently: user.profile?.currentLocation, nextStop: user.profile?.nextStop)
            return cell
            
        case 4:
            if ((user.profile?.interests ?? []).count > 0) {
                let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileTagsTableViewCell.reuseIdentifier, for: indexPath) as! EditProfileTagsTableViewCell
                cell.set(tags: (user.profile?.interests)!, plusButtonTouchedInside: plusButtonTouchedInside)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EditProfileAddTagsTableViewCell.reuseIdentifier, for: indexPath) as! EditProfileAddTagsTableViewCell
                cell.set(plusButtonTouchedInside: plusButtonTouchedInside)
                return cell
            }
            
        default: fatalError(String(format: "No matching cell type found for index path section: %d", indexPath.section))
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch (section) {
        case 1: return L10n.ProfileEditViewController.Header.basicInfo
        case 2: return L10n.ProfileEditViewController.Header.bio
        case 3: return L10n.ProfileEditViewController.Header.whereYoureAt
        case 4: return L10n.ProfileEditViewController.Header.whatYoureInto
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
        headerViewLabel.text?.capitalizeFirstLetter()
        headerView.addSubview(headerViewLabel)
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 1
        default: return 20
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch (indexPath.section) {
        case 0: return 270
        case 1: return 100
            // NOTE: Adjust height depending on max character limit for bio
        // case 2: return 250
        case 4:
            if (hasTags) {
                return UITableView.automaticDimension
            } else {
                return 60
            }
            
        default: return UITableView.automaticDimension
        }
    }
    
    private func plusButtonTouchedInside() {
        FirbaseAnalytics.logEvent(.profileTags)
        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" : "tags"])

        let editTagsViewController = ProfileEditTagsViewController(tags: user.profile?.interests ?? [], tagsUpdated: { tags in
            self.user.profile?.interests = tags.map({$0 as! String})
            self.tableView.reloadRows(at: [IndexPath.init(row: 0, section: 4)], with: .automatic)
        })
        
        self.navigationController?.pushViewController(editTagsViewController, animated: true)
    }
}

// MARK: - AboutMeLocationTableViewCellDelegate
extension ProfileEditViewController: AboutMeLocationTableViewCellDelegate {
    func deleteLocation(_ cell: AboutMeLocationTableViewCell, deleteLocationfor locationType: AboutMeLocationType) {
        // TODO : delete cell
        FirbaseAnalytics.logEvent(locationType == AboutMeLocationType.currently ?
            .editCurrently : locationType == AboutMeLocationType.next ?
                .editNextStop : .editHomeTown)
    }
    
    func aboutMeLocationCell(_ cell: AboutMeLocationTableViewCell, showGooglePlaceforLocation locationType: AboutMeLocationType) {
        AmplitudeAnalytics.logEvent(.editProfileItems, group: .myProfile, properties: ["item" :locationType.rawValue])

        gmsLocationType = locationType
        self.showGooglePlacesController()
    }
}

// MARK: - GMSAutocompleteViewControllerDelegate
extension ProfileEditViewController: GMSAutocompleteViewControllerDelegate {
    
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
    
    // User canceled the operation.
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


extension String {
    func toUsername() -> String {
        return self.lowercased().replacingOccurrences(of: " ", with: "")
    }
}


extension ProfileEditViewController {
    
    func post(user: User) {
        taskGroup.enter()
        App.transporter.post(user, returnType: User.self) { (result) in
            if let username = self.username, result?.username != username {
                self.showMessagePrompt(message: L10n.ProfileEditViewController.usernameTakenError, title: "", action: L10n.Common.gotIt, handler: { (action) in
                    self.taskGroup.leave()
                })
            } else {
                self.taskGroup.leave()
            }
        }
    }
}
