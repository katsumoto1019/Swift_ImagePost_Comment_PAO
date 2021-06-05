//
//  RegisterViewController.swift
//  Pao
//
//  Created by Parveen Khatkar on 2/6/18.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit


class RegisterViewController: BaseViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var emailTextField: IsaoTextField!
    @IBOutlet weak var fullNameTextField: IsaoTextField!
    @IBOutlet weak var usernameTextField: IsaoTextField!
    @IBOutlet weak var nextButton: UIButton!
    
    //Mark - Api Response Error Codes
    let usernameExists = 201;
    let emailExists = 202;
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        screenName = "Join Pao";
        title = L10n.Common.joinPao
        
        setupInputs();
        
        //download privacy policy pdf file before going to that screen. This will avoid the loading time on privacy-policy screen.
       /* PrivacyPolicyViewController().downloadPrivacyPolicy() */
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        styleButtons();
        setupNavigationBar();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        fullNameTextField.beginEditting();
    }
    
    func styleButtons() {
        nextButton.tintColor = ColorName.accent.color
        nextButton.setTitle("", for: .normal)
        updateNextButtonState();
    }
    
    //make naivigattion bar transparent clear
    func setupNavigationBar() {
        
    }
    
    func setupInputs() {
        setup(textField:fullNameTextField, placeholder: L10n.RegisterViewController.fullName, nextTextField: emailTextField);
        setup(textField:emailTextField, placeholder: L10n.RegisterViewController.email, nextTextField: usernameTextField);
        setup(textField:usernameTextField, placeholder: L10n.RegisterViewController.username, nextTextField: nil);
    }
    
    func setup(textField: IsaoTextField, placeholder: String, nextTextField: IsaoTextField?) {
        textField.attributedPlaceholder =
            NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]);
        textField.autocorrectionType = .no;
        textField.nextTextField = nextTextField;
        textField.endEdittingCallback = { textField in _ = self.validateInput(textField: textField) };
        textField.textChangedCallback = { textField in self.updateNextButtonState() };
        textField.returnKeyPressed = { textField in
            if  textField == self.usernameTextField {
                self.register();
                return true;
            }
            return false;
        };
    }
    
    func validateInput(textField: IsaoTextField, setErrorMessage: Bool = true) -> Bool {
        guard textField.text != nil && !textField.text!.isEmptyOrWhitespace else {
            if setErrorMessage {
                textField.error = textField == fullNameTextField ? L10n.RegisterViewController.errorFullName :
                    textField == emailTextField ? L10n.RegisterViewController.errorEmail :
                    L10n.RegisterViewController.errorUsername;
            }
            return false;
        }
        
        if textField == emailTextField, !textField.text!.trim.isValidEmail {
            if setErrorMessage { textField.error = L10n.RegisterViewController.errorEmail }
            return false;
        }
        
        let usernameRegex = "^[a-z0-9_-]{3,15}$"
        if textField == usernameTextField, let text = textField.text, !text.regexCheck(regex: usernameRegex) {
            if setErrorMessage { textField.error = "Username cannot contain special characters"; }
            return false;
        }
        
        return true;
    }
    
    @IBAction func showPasswordViewController(_ sender: Any) {
        register();
    }
    
    private func updateNextButtonState() {
        nextButton.isEnabled = validateInput(textField: fullNameTextField, setErrorMessage: false) &&
            validateInput(textField: emailTextField, setErrorMessage: false) &&
            validateInput(textField: usernameTextField, setErrorMessage: false);
    }
}


extension RegisterViewController {
    func register(){
        guard validateInput(textField: fullNameTextField) &&
            validateInput(textField: emailTextField) &&
            validateInput(textField: usernameTextField) else {return}
        
        nextButton.isEnabled = false;
        
        AmplitudeAnalytics.logEvent(.enterUserName, group: .onBoarding)

        let email = emailTextField.text!.trim;
        let username = usernameTextField.text!.toUsername();
        let params = AccountTakenParams(email: email, username: username);
        App.transporter.get(AccountTaken.self, queryParams: params) { (result) in
            if let result = result {
                self.callbackHandler(accountTaken: result);
            } else {
                self.nextButton.isEnabled = true;
            }
        }
    }
    
    func callbackHandler(accountTaken: AccountTaken) {
        updateNextButtonState();
        
        if accountTaken.isEmailTaken == true {
            emailTextField.error = L10n.RegisterViewController.errorEmailAlreadyInUse;
        }
        
        if accountTaken.isUsernameTaken == true {
            usernameTextField.error = L10n.RegisterViewController.errorUsernameAlreadyInUse;
        }
        
        if accountTaken.isUsernameTaken == true || accountTaken.isEmailTaken == true {return}
        
        let viewController = PasswordViewController(email: self.emailTextField.text!.trim, fullName: self.fullNameTextField.text!, username: self.usernameTextField.text!.toUsername());
        self.navigationController?.pushViewController(viewController, animated: true);
    }
}
