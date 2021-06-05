//
//  NewPaoAlertViewController.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 20.07.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

final class NewPaoAlertViewController: UIViewController {

	lazy var titleLabel: UILabel = {
		let textLabel = UILabel()
        textLabel.font = UIFont.appNormal.withSize(UIFont.sizes.large)
        textLabel.textColor = ColorName.textWhite.color
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 1
		return textLabel
	}()

	lazy var descriptionLabel: UILabel = {
		let textLabel = UILabel()
        textLabel.font = UIFont.appLight.withSize(UIFont.sizes.small)
        textLabel.textColor = ColorName.textWhite.color
        textLabel.textAlignment = .center
        textLabel.numberOfLines = 4
		return textLabel
	}()

	lazy var actionButton: UIButton = {
		let button = UIButton()
        button.setTitleColor(ColorName.textWhite.color, for: .normal)
        button.backgroundColor = ColorName.background.color
        button.titleEdgeInsets = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: 6)
        button.titleLabel?.font = UIFont.appMedium.withSize(14)
        button.addTarget(self, action: #selector(tapButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}()

	lazy var imageView: UIImageView = {
		let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
		return image
	}()

    lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

	lazy var stackView: UIStackView = {
		let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
		return stackView
	}()

    private var gradient: CAGradientLayer?

    var action: (()->())?
    var closing: (()->())?

    init(title: String, description: String, image: UIImage? = nil, buttonText: String) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        descriptionLabel.text = description
        imageView.image = image
        actionButton.setTitle(buttonText, for: .normal)

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
        modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(contentView)
        gradient = contentView.linearGradient(
            colors: [ColorName.greenAlertGradinentStart.color.cgColor,
                     ColorName.greenAlertGradinentEnd.color.cgColor],
            start: CGPoint(x: 0.35, y: 0),
            end: CGPoint(x: 0.65, y: 1)
        )

        if let gradient = gradient {
            contentView.layer.addSublayer(gradient)
        }
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(descriptionLabel)
        stackView.addArrangedSubview(actionButton)

        view.backgroundColor = ColorName.background.color.withAlphaComponent(0.8)

        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalToConstant: 297),
            contentView.heightAnchor.constraint(equalToConstant: 400),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.9),
            stackView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.85),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 131),
            imageView.widthAnchor.constraint(equalToConstant: 131),
            actionButton.widthAnchor.constraint(equalToConstant: 182),
            actionButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        contentView.layer.cornerRadius = 7.0
        gradient?.frame = contentView.bounds
        gradient?.cornerRadius = contentView.layer.cornerRadius

        actionButton.layer.cornerRadius = actionButton.frame.height / 2
    }

    @objc func tapButton() {
        action?()
    }

    @objc func close() {
        closing?()
        dismiss(animated: true)
    }
}
