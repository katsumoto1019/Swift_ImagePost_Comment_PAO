//
//  NotificationsSettingsTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 10/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit


class NotificationsSettingsTableViewController: StyledTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Notification Settings";
        
        tableView.register(KeySwitchTableViewCell.self);
        tableView.register(LabelTableViewCell.self);
        tableView.separatorColor = .clear;
        tableView.contentInset.top = 24;
        tableView.rowHeight = UITableView.automaticDimension;
        
        
        if DataContext.cache.user.settings == nil {
            DataContext.cache.user.settings = UserSettings();
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        title = L10n.NotificationsSettingsTableViewController.title;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = "";
    }
    
    override func willMove(toParent parent: UIViewController?) {
        if parent == nil {
            navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default);
            navigationController?.navigationBar.isTranslucent = true;
        }
        super.willMove(toParent: parent)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 0 ? KeySwitchTableViewCell.reuseIdentifier : LabelTableViewCell.reuseIdentifier, for: indexPath);
        
        if let keySwitchCell = cell as? KeySwitchTableViewCell {
            keySwitchCell.set(key: "Push Notifications", value: DataContext.cache.user.settings?.isNotificationEnabled ?? true) { (value) in
                FirbaseAnalytics.logEvent(.toggleNitifications)
                AmplitudeAnalytics.logEvent(.toggleNotification, group: .settings, properties: ["isEnabled" : value])
                
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    AmplitudeAnalytics.setUserProperty(property: .notificationStatus, value: NSNumber(value: settings.authorizationStatus == .authorized))
                }

                DataContext.cache.user.settings?.isNotificationEnabled = value;
                self.post(settings: DataContext.cache.user.settings!);
            }
        }
        
        if let labelCell = cell as? LabelTableViewCell {
            labelCell.set(title: L10n.NotificationsSettingsTableViewController.labelText);
        }
        
        return cell;
    }
}


extension NotificationsSettingsTableViewController {
    func post(settings: UserSettings) {
        let user = User()
        user.settings = settings
        App.transporter.post(user) { (result) in
            print("settings : \(String(describing: result))")
        }
    }
}
