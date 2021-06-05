//
//  ForgotPasswordViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 3/9/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import Firebase

class ForgotPasswordViewController: BaseViewController {

    @IBOutlet weak var emailTextField: UnderlineTextField!
    @IBOutlet weak var submitButton: RoundCornerButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Forgot Password";
        
        submitButton.setTitle(L10n.ForgotPasswordViewController.submitButton, for: .normal)
        descriptionLabel.text = L10n.ForgotPasswordViewController.descriptionLabel
        
        applyStyle();
        setupNavigationBar();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.barTintColor = ColorName.navigationBarTint.color
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationItem.title = L10n.ForgotPasswordViewController.title
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: Asset.Assets.Icons.leftArrowNav.image,
            style: .plain,
            target: self,
            action: #selector(dismissViewController)
        )
    }

    @IBAction func sendRecoveryEmail(_ sender: Any) {
        self.view.endEditing(true);
        
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
            if let errorMessage = error?.localizedDescription {
                self.showMessagePrompt(message: errorMessage, customized: true);
                return;
            }
            
           /* self.showMessagePrompt(message: "A link has been sent to your email so you can reset your password.", title: "Sent!", customized: true, handler: { (alertAction) in
                self.dismissViewController();
            });*/
            let alert = PaoAlertController.init(title: L10n.ForgotPasswordViewController.PaoAlert.title, subTitle: L10n.ForgotPasswordViewController.PaoAlert.subTitle)
            alert.addButton(title: L10n.Common.gotIt, onClick: {
                self.navigationController?.popViewController(animated: true);
            })
            alert.show(parent: self)
        }
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true, completion: nil);
    }
}
