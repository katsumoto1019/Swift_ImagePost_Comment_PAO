//
//  PushNotificationAlertController.swift
//  Pao
//
//  Created by MACBOOK PRO on 17/07/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class UserPermissionsAlertViewController: UIViewController {
    
    private var textString: String?
    
    public var containerView: UIView = UIView()
    private var containerStackView = UIStackView()
    private var personalDataStackView = UIStackView()
    private var newsletterStackView = UIStackView()
    
    private var buttons = [UIButton]()
    private var labels = [UILabel]()
    private var checkBoxes = [UIButton]()
    
    private var buttonContainers = [UIView]()
    private var checkboxContainer = [UIView]()
    
    private let gradientLayer:CAGradientLayer = CAGradientLayer();
    
    public var permissions = Permissions();
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupContainerViews();
        setupSubViews();
        addConstraints();
        applyStyle();
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame.size = containerView.frame.size
    }
    
    private func setupContainerViews() {
        containerView.makeCornerRound(cornerRadius: 5)
        
        containerStackView.axis = .vertical;
        
        personalDataStackView.axis = .horizontal;
        personalDataStackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 0, right: 16);
        personalDataStackView.isLayoutMarginsRelativeArrangement = true;
        
        newsletterStackView.axis = .horizontal;
        newsletterStackView.layoutMargins = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16);
        newsletterStackView.isLayoutMarginsRelativeArrangement = true;
        
        containerView.translatesAutoresizingMaskIntoConstraints = false;
        containerStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        containerStackView.addArrangedSubview(personalDataStackView);
        containerStackView.addArrangedSubview(newsletterStackView);
        containerView.addSubview(containerStackView);
        view.addSubview(containerView);
    }
    
    private func addConstraints() {
        var constraints = [
            containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ];
        
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        
        constraints.append(personalDataStackView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor));
        constraints.append(personalDataStackView.heightAnchor.constraint(equalToConstant: 140));
        
        constraints.append(newsletterStackView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor));
        constraints.append(newsletterStackView.heightAnchor.constraint(equalToConstant: 95));
        
        buttons.forEach { (button) in
            constraints = constraints + [
                button.superview!.heightAnchor.constraint(equalToConstant: 40),
                button.heightAnchor.constraint(equalToConstant: 30),
                button.widthAnchor.constraint(equalToConstant: 150),
                button.centerXAnchor.constraint(equalTo: button.superview!.centerXAnchor)
            ]
        }
        
        checkBoxes.forEach { (checkBox) in
            constraints = constraints + [
                checkBox.superview!.widthAnchor.constraint(equalToConstant: 30),
                checkBox.heightAnchor.constraint(equalToConstant: 20),
                checkBox.widthAnchor.constraint(equalToConstant: 20),
                checkBox.topAnchor.constraint(equalTo: checkBox.superview!.topAnchor, constant: 8)
            ]
        }
        
        NSLayoutConstraint.activate(constraints);
        view.layoutIfNeeded();
    }
    
    private func applyStyle() {
        view.backgroundColor = UIColor.clear;
        containerView.backgroundColor = UIColor.clear;
        
        buttons.forEach {
            $0.titleLabel?.font = UIFont.appMedium.withSize(UIFont.sizes.small)
            $0.backgroundColor = .white
            $0.makeCornerRound(cornerRadius: 13)
        }
        
        labels.forEach {
            $0.textColor = ColorName.textWhite.color
            $0.textAlignment = .left;
            $0.font = UIFont.appMedium.withSize(UIFont.sizes.small);
        }
        
        checkBoxes.forEach {
            $0.setImage(Asset.Assets.Icons.checkBox.image, for: .normal)
            $0.setImage(Asset.Assets.Icons.checkboxselected.image, for: .selected)
        }
        
        gradientLayer.colors = [ColorName.accent.color.cgColor,  ColorName.gradientBottom.color.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint.init(x: 0.7, y: 1.0)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.alpha = 0.9;
    }
    
    private func setupSubViews() {
        let personalDataCheckBox = UIButton();
        checkBoxes.append(personalDataCheckBox);
        
        personalDataCheckBox.addAction(for: .touchUpInside) { [weak self] in
            personalDataCheckBox.isSelected = !personalDataCheckBox.isSelected;
            self!.permissions.personalData = personalDataCheckBox.isSelected;
        }
        
        let personalContainerView = UIView();
        personalContainerView.backgroundColor = UIColor.clear;
        personalContainerView.addSubview(personalDataCheckBox)
        checkboxContainer.append(personalContainerView)
        personalDataCheckBox.translatesAutoresizingMaskIntoConstraints = false;
        personalDataStackView.addArrangedSubview(personalDataCheckBox.superview!);
        
        let personalDataLabel = UILabel();
        personalDataLabel.numberOfLines = 0;
        personalDataLabel.text = L10n.UserPermissionsAlertViewController.PersonalDataLabel.text;
        personalDataLabel.translatesAutoresizingMaskIntoConstraints = false;
        personalDataStackView.addArrangedSubview(personalDataLabel);
        labels.append(personalDataLabel);
        
        let newsletterCheckBox = UIButton();
        checkBoxes.append(newsletterCheckBox);
        
        newsletterCheckBox.addAction(for: .touchUpInside) { [weak self] in
            newsletterCheckBox.isSelected = !newsletterCheckBox.isSelected;
            self!.permissions.newsletter = newsletterCheckBox.isSelected;
        }
        
        let newsletterContainerView = UIView();
        newsletterContainerView.backgroundColor = UIColor.clear;
        newsletterContainerView.addSubview(newsletterCheckBox)
        checkboxContainer.append(newsletterContainerView)
        newsletterCheckBox.translatesAutoresizingMaskIntoConstraints = false;
        newsletterStackView.addArrangedSubview(newsletterCheckBox.superview!);
        
        let newsletterLabel = UILabel();
        newsletterLabel.numberOfLines = 0;
        newsletterLabel.text = L10n.UserPermissionsAlertViewController.NewsletterLabel.text
        newsletterLabel.translatesAutoresizingMaskIntoConstraints = false;
        newsletterStackView.addArrangedSubview(newsletterLabel);
        labels.append(newsletterLabel);
        
        //If no button has been added, then add default button to dismiss the screen.
        if buttons.count <= 0 {
            addButton(title: L10n.Common.ok, onClick: {});
        }
        
        buttons.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false;
            containerStackView.addArrangedSubview($0.superview!);
        };
    }
    
    func addButton(title: String, onClick: @escaping () -> Void) {
        let button = UIButton();
        button.setTitle(title, for: .normal);
        button.setTitleColor(ColorName.accent.color, for: .normal)
        buttons.append(button);
        
        button.addAction(for: .touchUpInside) { [weak self] in
            self?.dismiss(animated: true, completion: {
                onClick();
            })
        }
        
        let buttonContainerView = UIView();
        buttonContainerView.backgroundColor = UIColor.clear;
        buttonContainerView.addSubview(button)
        buttonContainers.append(buttonContainerView)
    }
    
    func show(parent: UIViewController) {
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve;
        parent.present(self, animated: true, completion: nil);
    }
    
    func dismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}

extension UserPermissionsAlertViewController {
    static public func showAlert(title: String, message: String,  parent: UIViewController) {
        let alert = UserPermissionsAlertViewController();
        alert.addButton(title: L10n.Common.ok) {}
        alert.show(parent: parent);
    }
}
