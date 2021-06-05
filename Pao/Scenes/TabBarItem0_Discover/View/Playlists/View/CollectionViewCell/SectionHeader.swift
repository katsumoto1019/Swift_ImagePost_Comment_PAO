//
//  SectionHeader.swift
//  Pao
//
//  Created by Podkladov Anatoliy Olegovich on 18.06.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class SectionHeader: UICollectionReusableView {

	private var baseLabel: UILabel {
		let label = UILabel()
		label.numberOfLines = 0
		label.textColor = .white
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		return label
	}

	lazy var titleLabel: UILabel = {
		let label = baseLabel
		label.font = UIFont.appHeavy.withSize(UIFont.sizes.sectionTitle)

		return label
	}()

	lazy var subtitleLabel: UILabel = {
		let label = baseLabel
		label.font = UIFont.appLight.withSize(UIFont.sizes.verySmall)

		return label
	}()

	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(titleLabel)
		addSubview(subtitleLabel)

		[
			titleLabel.topAnchor.constraint(equalTo: topAnchor),
			titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
			titleLabel.rightAnchor.constraint(equalTo: rightAnchor),

			subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
			subtitleLabel.leftAnchor.constraint(equalTo: leftAnchor),
			subtitleLabel.rightAnchor.constraint(equalTo: rightAnchor)
			].forEach {
				$0.isActive = true
		}
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
