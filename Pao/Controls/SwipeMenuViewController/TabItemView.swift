import UIKit

final class TabItemView: UIView {

    enum Style {
        case imageView(image: UIImage)
        case label(text: String)
    }

    private(set) var titleLabel: UILabel = {
        var titleLabel: UILabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
        titleLabel.backgroundColor = UIColor.clear
        return titleLabel
    }()

    private(set) var dotView: UIView =  {
        var dotView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: 8))
        dotView.backgroundColor = ColorName.accent.color
        dotView.layer.cornerRadius = dotView.frame.height / 2
        dotView.layer.masksToBounds = true
        dotView.isHidden = true
        return dotView
    }()
    
    private(set) var imageView: UIImageView = UIImageView()

    var textColor: UIColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
    var selectedTextColor: UIColor = .white

    var isSelected: Bool = false {
        didSet {
            if isSelected {
                titleLabel.textColor = selectedTextColor
            } else {
                titleLabel.textColor = textColor
            }
        }
    }

    public init(frame: CGRect, style: Style) {
        super.init(frame: frame)
        setup(style: style)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
    }

    private func setup(style: Style) {

        switch style {
        case .imageView:
            addSubview(imageView)
            layoutImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.clipsToBounds = true
        case .label:
            titleLabel = UILabel(frame: bounds)
            addSubview(titleLabel)
            layoutLabel()
        }
    }

    private func layoutLabel() {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor),
            titleLabel.widthAnchor.constraint(equalTo: self.widthAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    private func layoutImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 20),
        ])
    }
}
