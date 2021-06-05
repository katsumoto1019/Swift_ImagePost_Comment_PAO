//
//  PaoAlertControllNew.swift
//  Pao DEV
//
//  Created by Waseem Ahmed on 14/06/2019.
//  Copyright © 2019 Exelia. All rights reserved.
//

import UIKit

class PaoAlertControllerNew: UIViewController {
    
    private var titleString: String?
    private var subTitleString: String?
    
    private var containerView: UIView = UIView()
    private var containerStackView = UIStackView()
    private var textStackView = UIStackView()
    
    private var buttons = [UIButton]()
    private var labels = [UILabel]()
    
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
    
    private func setupContainerViews() {
        containerView.drawBorder(color:UIColor.accent, borderWidth: 2.5, cornerRadius: 0);
        
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
        constraints = constraints + NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[stackView]-0-|", options: [], metrics: nil, views: ["stackView" : containerStackView]);
        
        constraints.append(textStackView.widthAnchor.constraint(equalTo: containerStackView.widthAnchor));
        
        constraints = constraints + buttons.map({$0.heightAnchor.constraint(equalToConstant: 40)});
        
        NSLayoutConstraint.activate(constraints);
        view.layoutIfNeeded();
    }
    
    private func applyStyle() {
        view.backgroundColor = UIColor.background.withAlphaComponent(0.8);
        containerView.backgroundColor = UIColor.background;
        
        buttons.forEach {
            $0.titleLabel?.font = UIFont.app;
            $0.addBorder(edge: .top, color: UIColor.accent, thickness: 1);
        }
        
        labels.forEach {
            $0.textColor = UIColor.textWhite;
            $0.textAlignment = .center;
        }
    }
    
    private func setupSubViews() {
        if let label = addLabel(forText: titleString) {
            label.font = UIFont.appHeavy.withSize(UIFont.sizes.normal);
        }
        
        if let label = addLabel(forText: subTitleString) {
            label.font = UIFont.app;
        }
        
        //If no button has been added, then add default button to dismiss the screen.
        if buttons.count <= 0 {
            addButton(title: "OK", style: .normal, onClick: {});
        }
        
        buttons.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false;
            containerStackView.addArrangedSubview($0);
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
    
    func addButton(title: String, style: ButtonStyle, onClick: @escaping () -> Void) {
        let button = UIButton();
        button.setTitle(title, for: .normal);
        buttons.append(button);
        
        button.addAction(for: .touchUpInside) { [weak self] in
            self?.dismiss(animated: true, completion: {
                onClick();
            })
        }
        
        switch style {
        case .additional:  button.setTitleColor(UIColor.placeholder, for: .normal); break;
        default: button.setTitleColor(UIColor.accent, for: .normal); break;
        }
    }
    
    func show(parent: UIViewController) {
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext;
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve;
        parent.present(self, animated: true, completion: nil);
    }
}

//Mark - Button will have two styles. Normal: with theme color. Additional: with faded color
enum ButtonStyle {
    case normal
    case additional
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

extension UIControl {
    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping ()->()) {
        let sleeve = ClosureSleeve(closure);
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke), for: controlEvents);
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN);
    }
}


