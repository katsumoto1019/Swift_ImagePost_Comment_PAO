//
//  NetworkViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 28/11/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

import RocketData
import FirebaseMessaging
import Firebase
import SwiftLocation

class NetworkViewController: BaseViewController {
    
    // MARK: - Dependencies
    
    private lazy var splashAnimViewController = LogoAnimViewController()
    
    // MARK: - Internal properties
    
    /// Make this flag false when you don't want to make apiCheck call from viewDidLoad.
    var checkApiVersion = false
    
    /// Behaviour dependant on where the screen loads from
    var didComeFromOB = false
    
    /// Make this flag true if we want to show splash animations, instead of the loader
    var splashAnimation = false
    
    // MARK: - Private properties
    
    private var isValidApiCode = false
    private var isTokenLoaded = false
    private var activityIndicatorView: NVActivityIndicatorView?
    
    // MARK: - Lifecycle
    
    init(splashAnim: Bool = false, didComeFromOB: Bool = false) {
        super.init(nibName: nil, bundle: nil)
        
        self.splashAnimation = splashAnim
        self.didComeFromOB = didComeFromOB
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DataModelManager.resetSharedInstance()
        
        if !splashAnimation {
            let frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            activityIndicatorView = NVActivityIndicatorView(
                frame: frame,
                type: .circleStrokeSpin,
                color: ColorName.textGray.color,
                padding: 8
            )
            
            activityIndicatorView?.startAnimating()
            
            view.addSubview(activityIndicatorView!)
            activityIndicatorView?.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorView?.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            activityIndicatorView?.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        } else {
            splashLogo()
        }
        
        // when data is userData is loaded
        NotificationCenter.default.addObserver(self, selector: #selector(userLoaded(notification:)), name: .initialDataLoaded, object: nil)
        
        //When firebase UserToken is loaded/updated
        NotificationCenter.default.addObserver(self, selector: #selector(tokenLoaded(notification:)), name: .tokenLoaded, object: nil)
        
        // When fetching userDetails from server gets errorW
        NotificationCenter.default.addObserver(self, selector: #selector(userUpdateError(notification:)), name: .userUpdateError, object: nil)
        
        //Following code is also being called from networkStateChange callback.
        if (!self.didComeFromOB) {
            self.apiVersion()
        }
        
        //To make it false if user logsOut and logsIn again, while having this flag was true
        UploadBoardCollectionViewController.uploadInProgress = false
    }
    
    override func networkChanged(online: Bool) {
        if online {
            if self.checkApiVersion && !self.didComeFromOB {
                // somehow the original call does not always retry (for example, no network at all) [EG]
                self.apiVersion(retry: true) // now true, to also retry if you opened app with no network and then got access later
            }
        } else {
            activityIndicatorView?.stopAnimating()
        }
    }
    
    func apiVersion(retry: Bool? = true) {
        bfprint("-= SOS =- apiVersion")
        
        activityIndicatorView?.startAnimating()
        
        let url = App.transporter.getUrl(ApiVersion.self, httpMethod: .get)
        APIManager.callAPIForWebServiceOperation(model: ApiVersion(), urlPath: url, methodType: "GET") { (apiStatus, apiVersion: ApiVersion?, responseObject, statusCode) in
            if(apiStatus){
                // Skip calling this again until the initial one is called at least once [EG]
                self.checkApiVersion = true
                
                print("*** apiVersion: \(String(describing: apiVersion?.version)), retry: \(retry == true ? "yes" : "no")")
                // if the response has an error, it will return false of <T> or nil in this case
                // so let it retry only once after 2 seconds [EG]
                guard let apiVersion = apiVersion else {
                    if let retry = retry, retry {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                            self.apiVersion()
                        }
                    }
                    return
                }
                
                //apiVersion() is being called twice some times, so the following check is added to handle it.
                if self.isValidApiCode { return }
                
                guard let version = apiVersion.version else {return}
                
                if version > Bundle.main.apiVersionCode {
                    self.showForceUpdateAlert(title: L10n.NetworkViewController.ForceUpdateAlert.title, message: L10n.NetworkViewController.ForceUpdateAlert.message) { (action: UIAlertAction) in
                        // open app store
                        if let url = URL(string: "itms-apps://apps.apple.com/us/app/the-pao-app/id1398395194") {
                            if UIApplication.shared.canOpenURL(url) {
                                UIApplication.shared.open(url)
                            }
                        }
                        
                    }
                    return
                }
                self.isValidApiCode = true
                
                self.initializeCache()
                if self.didComeFromOB {
                    // if comes from onboarding, free the objects
                    gSlide1 = nil
                    gSlide2 = nil
                    gSlide3 = nil
                    gSpots = nil
                }
            }
        }
    }
    
    @objc
    private func userLoaded(notification: Notification) {
        if splashAnimation {
            splashAnimViewController.animate(delay: 0.2, callback: {
                self.showMainView()
            })
        } else {
            showMainView()
        }
    }
    
    @objc
    private func tokenLoaded(notification: Notification) {
        guard !isTokenLoaded, isValidApiCode else {return}
        
        initializeCache()
    }
    
    @objc
    private func userUpdateError(notification: Notification) {
        guard (UIApplication.shared.delegate as! AppDelegate).reachabilityService?.isOnline() ?? true else { return }
        
        do {
            Messaging.messaging().unsubscribe(fromTopic: Auth.auth().currentUser?.uid ?? "")
            //Messaging.messaging().unsubscribe(fromTopic: PNTopics.playlistUpdate.rawValue) // no need to unsub (not user specific) [EG]
            //Messaging.messaging().unsubscribe(fromTopic: PNTopics.forceUpdate.rawValue) // no need to unsub (not user specific) [EG]
            try Auth.auth().signOut()
            AmplitudeAnalytics.logOut()
            AppDelegate.startAccountFlow()
        } catch {
            #if DEBUG
            print("Error signing out: \(error)")
            #endif
        }
    }
    
    private func initializeCache() {
        bfprint("-= SOS =- initializeCache")
        
        // If currentUser is nil, then show loginScreen
        if Auth.auth().currentUser != nil {
            
            if App.transporter.headers["Authorization"] != nil {
                isTokenLoaded = true
                self.updateUserLocation()
                DataContext.cache.load()
            }
        } else {
            loginScreen()
        }
    }
    
    private func showMainView() {
        bfprint("-= SOS =- showMainView")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        // Don't show tutorials if user is not a new registration.
        if !self.didComeFromOB {
            setupUserDefaults()
        } else {
            // If its comming from registration screen, then reset again, becasue the dummy view of tabBarViewController ischanging some values
            self.didComeFromOB = false
            UserDefaults.reset()
        }
        
        let tabBarController = TabBarController()
        appDelegate.window?.rootViewController = tabBarController
        
        NotificationCenter.default.removeObserver(self)
        
        // This is done too soon and causes issues like spinner on feed page.
        // It is redundant since it already exists in TabBarController.viewDidAppear
        //        if
        //            let notification = appDelegate.notificationOption as? [String: AnyObject],
        //            let _ = notification["type"] as? String {
        //            appDelegate.handleTapped(userInfo: notification)
        //            tabBarController.selectedTabIndex = 3
        //
        //            appDelegate.notificationOption = nil
        //        }
    }
    
    func updateUserLocation() {
        bfprint("-= SOS =- updateUserLocation")
        
        LocationManager.shared.locateFromIP(service: .ipApiCo) { result in
            switch result {
            case .failure(let error):
                debugPrint("An error has occurred while getting info about location: \(error)")
            case .success(let place):
                // Call endpoint
                let myPlace = MyPlace(place: place)
                let url = App.transporter.getUrl(MyPlace.self, httpMethod: .put)
                APIManager.callAPIForWebServiceOperation(model: myPlace, urlPath: url, methodType: "PUT") { (apiStatus, place: MyPlace?, responseObject, statusCode) in
                    if(apiStatus){
                        print("-= PN =- Place updated successfully")
                    }else{
                        print("-= PN =- Failed to update place")
                    }
                }
                // subscribe for notifications using city name as topic
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                if let city = myPlace.city {
                    if let regionCode = myPlace.regionCode {
                        let topic = "\(regionCode.lowercased()).\(city.lowercased())".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "\(regionCode.lowercased()).\(city.lowercased())"
                        appDelegate.subscribeSilentPNs(topic: topic)
                    } else {
                        let topic = city.lowercased().addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? city.lowercased()
                        appDelegate.subscribeSilentPNs(topic: topic)
                    }
                }
            }
        }
    }
    
    // MARK: - Private methods
    
    private func splashLogo() {
        view.addSubview(splashAnimViewController.view)
        splashAnimViewController.didMove(toParent: self)
        splashAnimViewController.view.constraintToFit(inContainerView: self.view)
    }
    
    private func loginScreen() {
        if splashAnimation {
            splashAnimViewController.animate(delay: 0.2, callback: {
                AppDelegate.startAccountFlow()
            })
        } else {
            AppDelegate.startAccountFlow()
        }
    }
    
    private func setupUserDefaults() {
        let defaults = UserDefaults.standard
        var keys = UserDefaultsKey.doneTutorialSpotKeys
        keys.append(UserDefaultsKey.doneTutorialForTabs)
        keys.forEach { defaults.set(true, forKey: $0.rawValue) }
        UserDefaults.standard.synchronize()
    }
    
    private func showForceUpdateAlert(title: String, message: String, action: ((UIAlertAction) -> Swift.Void)? = nil) {
        let alert = ForceUpdateAlertController(title: title, subTitle: message);
        alert.addButton(title: L10n.NetworkViewController.ForceUpdateAlert.buttonTitle) {
            action?(UIAlertAction())
        }
        alert.show(parent: self);
    }
}
