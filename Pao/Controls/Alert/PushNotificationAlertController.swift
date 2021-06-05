//
//  PushNotificationAlertController.swift
//  Pao
//
//  Created by MACBOOK PRO on 17/07/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class PushNotificationAlertController: UIViewController {
    
    private var textString: String?
    
    public var containerView: UIView = UIView()
    private var containerStackView = UIStackView()
    private var textStackView = UIStackView()
    
    private var labels = [UILabel]()
    
    private var buttonCnntainers = [UIView]()
    
    private let gradientLayer:CAGradientLayer = CAGradientLayer();
    
    init(text: String?) {
        super.init(nibName: nil, bundle: nil)
        
        self.textString = text;
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
        
        self.view.addGestureRecognizer( UITapGestureRecognizer.init(target: self, action: #selector(close)))
        self.view.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        gradientLayer.frame.size = containerView.frame.size
    }
    
    private func setupContainerViews() {
        containerView.makeCornerRound(cornerRadius: 5)
        
        containerStackView.axis = .vertical;
        
        textStackView.axis = .vertical;
        textStackView.layoutMargins = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16);
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
            containerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 20),
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ];
        
        constraints = constraints + [NSLayoutConstraint(item: containerView, attribute: .topMargin, relatedBy: .equal, toItem: containerView.superview, attribute: .topMargin, multiplier: 1.0, constant: 10.0)];
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        
        constraints.append(textStackView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor));
        
        NSLayoutConstraint.activate(constraints);
        view.layoutIfNeeded();
    }
    
    private func applyStyle() {
        view.backgroundColor = UIColor.clear;
        containerView.backgroundColor = UIColor.clear;
        
        labels.forEach {
            $0.textColor = ColorName.textWhite.color
            $0.textAlignment = .center;
        }
        
        gradientLayer.colors = [ColorName.accent.color.cgColor,  ColorName.gradientBottom.color.cgColor]
        gradientLayer.startPoint = CGPoint.init(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint.init(x: 0.7, y: 1.0)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        containerView.alpha = 1.0;
    }
    
    private func setupSubViews() {
        
        if let label = addLabel(forText: textString) {
            label.font = UIFont.appMedium.withSize(UIFont.sizes.small);
        }
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
    
    func show(parent: UIView) {
        self.close()
        
        let frame = CGRect(x: 0, y: parent.safeAreaInsets.top, width: parent.frame.width, height: 60)
        self.view.frame = frame
        parent.addSubview(self.view)
    }
    
    @objc private func close() {
        self.view.removeFromSuperview()
    }
    
    func dismiss(afterDelay delay: Double? = nil) {
        guard let delay = delay else {
            self.close()
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.close()
        }
    }
}
