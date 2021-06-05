//
//  SettingsTableViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 17/06/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit


class SettingsTableViewController: StyledTableViewController {
    private let titles = [
        L10n.SettingsTableViewController.optionAccount,
        L10n.SettingsTableViewController.optionPrivacy,
        L10n.SettingsTableViewController.optionDataDownload,
        L10n.SettingsTableViewController.optionNotifications,
        L10n.SettingsTableViewController.optionContact,
        L10n.SettingsTableViewController.optionAbout,
        L10n.SettingsTableViewController.optionEmojis,
        L10n.SettingsTableViewController.optionLogout
    ];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Settings";
        
        tableView.register(LabelTableViewCell.self);
        tableView.register(LogoutTableViewCell.self);
        tableView.separatorColor = .clear;
        tableView.contentInset.top = 24;
        
        navigationController?.navigationBar.backgroundColor = ColorName.navigationBarTint.color;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        title = L10n.SettingsTableViewController.title
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false;
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
       
        title = "";
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true;
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row < 7 ? LabelTableViewCell.reuseIdentifier : LogoutTableViewCell.reuseIdentifier, for: indexPath);

        if let labelCell = cell as? LabelTableViewCell {
            labelCell.set(title: titles[indexPath.row]);
            labelCell.accessoryType = .disclosureIndicator;
        }

        return cell;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(AccountTableViewController(), animated: true);
            break;
        case 1:
            navigationController?.pushViewController(PrivacySettingsTableViewController(), animated: true);
            break;
        case 2:
            // Add the data download call here //
            FirbaseAnalytics.logEvent(.dataDownload)
            AmplitudeAnalytics.logEvent(.dataDownload, group: .settings)
            
            let alert = PaoAlertController.init(title: nil, subTitle: L10n.SettingsTableViewController.PaoAlert.subTitle)
            alert.addButton(title: L10n.SettingsTableViewController.PaoAlert.buttonText) {
                self.gdpr()
            }
            alert.addButton(title: L10n.Common.cancel) {}
            alert.show(parent: self)
            
            break
        case 3:
            navigationController?.pushViewController(NotificationsSettingsTableViewController(), animated: true);
            break;
        case 4:
            let emailContactService = EmailContactService(viewController: self);
            emailContactService.showOptions();
            break;
        case 5:
            FirbaseAnalytics.logEvent(.abountApp)
            AmplitudeAnalytics.logEvent(.settingsAboutApp, group: .settings)
            
            navigationController?.pushViewController(AboutTableViewController(), animated: true);
            break;
        case 6:
            FirbaseAnalytics.logEvent(.emojiSetting)
            AmplitudeAnalytics.logEvent(.settingsEmojis, group: .settings)
            
            navigationController?.pushViewController(EmojisTableViewController(), animated: true);
            break;
        default:
            print("hey");
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.row + 1 == titles.count ? 75 : 56;
    }
}

extension SettingsTableViewController {
    func gdpr() {
        App.transporter.get(ResponseStatus.self, for: type(of: self)) { [unowned self] (result) in
            
            if result?.status == true {
                self.showMessagePrompt(message: L10n.SettingsTableViewController.MessagePromptGDPR.message, title: L10n.SettingsTableViewController.MessagePromptGDPR.title, action: L10n.Common.gotIt, customized: true, handler: nil);
            } else {
                self.showMessagePrompt(message: L10n.SettingsTableViewController.ErrorMessagePrompt.message, title: "", action: L10n.Common.gotIt, customized: true, handler: nil);
            }
        }
    }
}
