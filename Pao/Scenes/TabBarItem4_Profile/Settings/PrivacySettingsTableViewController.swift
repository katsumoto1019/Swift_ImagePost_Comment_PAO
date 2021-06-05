//
//  PrivacySettingsTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 10/09/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Payload


class PrivacySettingsTableViewController: StyledTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Privacy Settings";
        
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
        title = L10n.PrivacySettingsTableViewController.title;
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
            keySwitchCell.set(key: "Private Account", value: (DataContext.cache.user.settings?.isPublic == false)) { (value) in
                FirbaseAnalytics.logEvent(.makePrivate)
                AmplitudeAnalytics.logEvent(.settingsPrivate, group: .settings, properties: ["isPublic" : !value])

                DataContext.cache.user.settings?.isPublic = !value;
                self.post(settings: DataContext.cache.user.settings!);
            }
        }
        
        if let labelCell = cell as? LabelTableViewCell {
            labelCell.set(title: L10n.PrivacySettingsTableViewController.labelText);
        }
        
        return cell;
    }
}

extension PrivacySettingsTableViewController {
    func post(settings: UserSettings) {
        let user = User()
        user.settings = settings;
                
        App.transporter.post(user, returnType: User.self) { (result) in
            print("settings : \(String(describing: result))")
        }
    }
}
