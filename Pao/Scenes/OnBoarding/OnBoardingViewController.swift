//
//  OnBoardingViewController.swift
//  Pao
//
//  Created by Waseem Ahmed on 23/10/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class OnBoardingViewController: BaseViewController {
    
    var index = 0
    
    let titles = [
        L10n.OnBoardingViewController.titleJoinCommunity,
        L10n.OnBoardingViewController.titleDiscoverHiddenGems,
        L10n.OnBoardingViewController.titleKeepTrack
    ]
    
    let descriptions = [
        L10n.OnBoardingViewController.descriptionNoNamelessReviewers,
        L10n.OnBoardingViewController.descriptionNoNegativeReviews,
        L10n.OnBoardingViewController.descriptionNeverForget
    ]
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var topGradientView: GradientView!
    
    //First OnBoarding screen
    let dataSource = ThirdBoardCollectionDataSource()
    
    //Second OnBoarding screen
    var spots = [Spot]()
    
    //Third OnBoarding screen
    let boardSlideDataSource = BoardSlideDataSource()
    
    init(index: Int) {
        super.init(nibName: nil, bundle: nil)
        self.index = index
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
         screenName = "OnBoard \(self.index)"
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        dataSource.reload()
        boardSlideDataSource.reload()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        invalidateTimers()
    }
    
    func invalidateTimers() {
        dataSource.scrollTimer?.invalidate()
    }
    
    override func applyStyle() {
        super.applyStyle()
        
        view.backgroundColor = .clear
        
        titleLabel.font = UIFont.appBold.withSize(UIFont.sizes.headerTitle + 2)
        descriptionLabel.textColor = ColorName.accent.color
        let matrix: CGAffineTransform = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(15 * .pi / 180)), d: 1, tx: 0, ty: 0)
        let desc: UIFontDescriptor = UIFontDescriptor(name: "Avenir-Medium", matrix: matrix)
        descriptionLabel.font = UIFont(descriptor: desc, size: UIFont.sizes.small-2)
        descriptionLabel.numberOfLines = 0
        containerView.backgroundColor = ColorName.background.color
        innerContainerView.backgroundColor = ColorName.background.color
        
        gradientView.gradientColors = [UIColor.black.withAlphaComponent(0.0), UIColor.black, UIColor.black]
        gradientView.isUserInteractionEnabled = false
        topGradientView.gradientColors = [UIColor.black, UIColor.black, UIColor.black.withAlphaComponent(0.0)]
        topGradientView.isUserInteractionEnabled = false
    }
    
    func setupViews() {
        titleLabel.text = titles[index]
        
        switch index {
        case 0:
            descriptionLabel.text = descriptions[index]
            setupFirstCollectionView()
            break
        case 1:
            descriptionLabel.text = descriptions[index]
//            readSpots()
            setupSpotViewController()
            break
        case 2:
            descriptionLabel.text = descriptions[index]
            setupThirdCollectionView()
            break
        default:
            break
        }
    }
    
    func setupFirstCollectionView() {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: dataSource.collectionLayout)
        
        containerView.addSubview(collectionView)
        collectionView.constraintToFit(inContainerView: containerView!)
        collectionView.isUserInteractionEnabled = false
        
        dataSource.attatch(to: collectionView)
        dataSource.reload()
    }
    
    func setupThirdCollectionView() {
        let collectionView = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: boardSlideDataSource.collectionLayout)
        
        containerView.addSubview(collectionView)
        collectionView.constraintToFit(inContainerView: containerView!)
        collectionView.isUserInteractionEnabled = false
        
        boardSlideDataSource.attatch(to: collectionView)
        boardSlideDataSource.reload()
    }
}
