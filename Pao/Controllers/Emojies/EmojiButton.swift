//
//  EmojiButton.swift
//  Pao
//
//  Created by Rybolovleva Olga Viktorovna on 15.08.2020.
//  Copyright © 2020 Exelia. All rights reserved.
//

import UIKit

class EmojiButton: UIButton {
    
    var emoji: Emoji?
	var onClick: ((Bool, Emoji) -> ())?
	var onLongPress: ((Emoji) -> ())?
	var onShowMenu: (() -> Void)?
    var delta = CGPoint(x: 0, y: 0)

    override var isSelected: Bool {
        didSet {
            if isSelected {
                backgroundColor = ColorName.emojiButtonSelectedBackground.color
            } else {
                backgroundColor = ColorName.emojiButtonBackground.color
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        get {
            return CGSize(width: 49, height: super.intrinsicContentSize.height)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            if !isSelected {
                self.transform = self.isHighlighted ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity
            }
        }
    }
    
	init(emoji: Emoji? = .none) {
        self.emoji = emoji
        super.init(frame: CGRect.zero)
        setLayer()
        self.addTarget(self, action: #selector(selectButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func set(count: Int) {
		backgroundColor = ColorName.emojiButtonBackground.color
        setTitle(count.abbreviated, for: .normal)
        titleLabel?.font = UIFont.appLight.withSize(16)
        titleLabel?.adjustsFontSizeToFitWidth = true
        titleLabel?.minimumScaleFactor = 0.5

        let imageSize = titleLabel?.text?.count ?? 0 > 1 ? CGSize(width: 15, height: 15) : CGSize(width: 20, height: 20)
        let image = emoji?.image.resize(for: imageSize)

        let contentEdge: UIEdgeInsets
        contentEdge = UIEdgeInsets(top: 7, left: 8, bottom: 7, right: 7)
        setInsets(forContentPadding: contentEdge, imageTitlePadding: 3)

        setImage(image, for: .normal)
		sizeToFit()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
		makeCornerRound(cornerRadius: 18)
    }

    private func setLayer() {
		if emoji == .none {
			imageView?.clipsToBounds = true
			imageView?.contentMode = .redraw
			backgroundColor = ColorName.emojiButtonBackground.color
			let resizeImage = Asset.Assets.Icons.addEmoji.image
			let image = resizeImage.resize(for: CGSize(width: 26, height: 22))
			contentEdgeInsets = UIEdgeInsets(top: 7, left: 10, bottom: 7, right: 8)
			setImage(image, for: .normal)
		} else {
            contentEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
            let image = emoji?.image.resize(for: CGSize(width: 24, height: 24))
            setImage(image, for: .normal)
		}
		sizeToFit()
    }

    @objc
	private func longPressAction() {
		if let emoji = emoji {
			onLongPress?(emoji)
        }
    }

    @objc
    private func selectButton() {
		if let emoji = emoji {
			isSelected = !isSelected
			onClick?(isSelected, emoji)
		} else {
			onShowMenu?()
		}
    }
}

extension EmojiButton {

    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: 0,
            left: imageTitlePadding,
            bottom: 0,
            right: -imageTitlePadding
        )
    }
}
