//
//  PaoAlertController.swift
//  Pao
//
//  Created by Waseem Ahmed on 29/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class PaoAlertController: UIViewController {
    
    private var titleString: String?
    private var subTitleString: String?
    
    private var containerView: UIView = UIView()
    private var containerStackView = UIStackView()
    private var textStackView = UIStackView()
    
    private var buttons = [UIButton]()
    private var labels = [UILabel]()
    
    private var buttonCnntainers = [UIView]()
    
    private let gradientLayer:CAGradientLayer = CAGradientLayer();
    
    init(title: String?, subTitle: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.titleString = title;
        self.subTitleString = subTitle;
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
    }
    
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
        
        textStackView.axis = .vertical;
        textStackView.spacing = 10;
        textStackView.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16);
        textStackView.isLayoutMarginsRelativeArrangement = true;
        
        textStackView.translatesAutoresizingMaskIntoConstraints = false;
        containerView.translatesAutoresizingMaskIntoConstraints = false;
        containerStackView.translatesAutoresizingMaskIntoConstraints = false;
        
        containerStackView.addArrangedSubview(textStackView);
        containerView.addSubview(containerStackView);
        view.addSubview(containerView);
        
    }
    
    private func addConstraints() {
        var constraints = [
            containerView.widthAnchor.constraint(equalToConstant: 250),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ];
        
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-12-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        
        constraints.append(textStackView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor));
        
        buttons.forEach { (button) in
            constraints = constraints + [
                button.superview!.heightAnchor.constraint(equalToConstant: 40),
                button.heightAnchor.constraint(equalToConstant: 30),
                button.widthAnchor.constraint(equalToConstant: 150),
                button.centerXAnchor.constraint(equalTo: button.superview!.centerXAnchor),
                button.centerYAnchor.constraint(equalTo: button.superview!.centerYAnchor)
            ]
        }
        //        constraints = constraints + buttons.map({$0.heightAnchor.constraint(equalToConstant: 40)});
        NSLayoutConstraint.activate(constraints);
        view.layoutIfNeeded();
    }
    
    private func applyStyle() {
        view.backgroundColor = ColorName.background.color.withAlphaComponent(0.8)
        containerView.backgroundColor = UIColor.clear;
        
        buttons.forEach {
            $0.titleLabel?.font = UIFont.appMedium.withSize(UIFont.sizes.small)
            $0.backgroundColor = .white
            $0.makeCornerRound(cornerRadius: 13)
        }
        
        labels.forEach {
            $0.textColor = ColorName.textWhite.color
            $0.textAlignment = .center;
        }
        
        //74FFC6
        gradientLayer.colors = [ColorName.gradientTop.color.cgColor,  ColorName.gradientBottom.color.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint.init(x: 0.7, y: 1.0)

        containerView.layer.insertSublayer(gradientLayer, at: 0);
    }
    
    private func setupSubViews() {
        if let label = addLabel(forText: titleString) {
            label.font = UIFont.appMedium.withSize(UIFont.sizes.large);
        }
        
        if let label = addLabel(forText: subTitleString) {
            label.font = UIFont.appMedium.withSize(UIFont.sizes.small);
        }
        
        //If no button has been added, then add default button to dismiss the screen.
        if buttons.count <= 0 {
            addButton(title: L10n.Common.gotIt, onClick: {});
        }
        
        buttons.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false;
            containerStackView.addArrangedSubview($0.superview!);
        };
    }
    
    private func addLabel(forText text: String?) -> UILabel? {
        
        guard text != nil else {return nil;}
        
        let label = UILabel();
        label.numberOfLines = 0;
        label.text = text;
        label.translatesAutoresizingMaskIntoConstraints = false;
        textStackView.addArrangedSubview(label);
        labels.append(label);
        return label;
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
        buttonCnntainers.append(buttonContainerView)
    }
    
    func show(parent: UIViewController) {
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve;
        parent.present(self, animated: true, completion: nil);
    }
}

//Mark -
private class ClosureSleeve {
    let closure: ()->();
    
    init (_ closure: @escaping ()->()) {
        self.closure = closure;
    }
    
    @objc func invoke () {
        closure();
    }
}


extension PaoAlertController {
    static public func showAlert(title: String, message: String,  parent: UIViewController) {
        let alert = PaoAlertController(title: title, subTitle: message);
        alert.addButton(title: L10n.Common.gotIt) {}
        alert.show(parent: parent);
    }
}
