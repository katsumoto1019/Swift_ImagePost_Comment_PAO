//
//  ProfileEditTagsViewController1.swift
//  Pao
//
//  Created by Waseem Ahmed on 24/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ProfileEditTagsViewController: BaseViewController {

    @IBOutlet weak var interestsLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    private var input = String.empty;
    private let tags: NSMutableArray;
        
    private var tagsUpdated : ((_ tags: NSMutableArray) -> Void)?
    
    var tagsCollectionViewController: TagsCollectionViewController!
    
    lazy var tagsInputView: TagsInputView = {
        let tagsView = Bundle.main.loadNibNamed( "TagsInputView", owner: self, options: nil)?.first as! TagsInputView;
        tagsView.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        tagsView.delegate = self;
        tagsView.selectedTags = self.tags as! [String];
        return tagsView;
    }()
    
    init(tags: [String], tagsUpdated: @escaping (_ tags: NSMutableArray) -> Void) {
        self.tags = NSMutableArray.init(array: tags);
        self.tagsUpdated = tagsUpdated;
        
        super.init(nibName: String(describing: ProfileEditTagsViewController.self), bundle: nil);
    }
    
    required init?(coder aDecoder: NSCoder) {
        tags = [];
        super.init(coder: aDecoder);
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        screenName = "Profile EditTags";
        
        setupNavBar();
        setupInterestsLabel();
        setupChildView();
        self.view.endEditing(true);
        //IQKeybaordMannager moves screen to up when keyboard is shown.we are disableing this because we are handling it manually.
        IQKeyboardManager.shared.disabledDistanceHandlingClasses.append(ProfileEditTagsViewController.self);
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8, execute: {
            self.tagsInputView.inputTextField.becomeFirstResponder();
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        title = L10n.ProfileEditTagsViewController.title
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        title = "";
    }

    private func setupNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: doneButton);
    }
    
    private func setupInterestsLabel() {
        interestsLabel.text = L10n.ProfileEditTagsViewController.interestsLabel
        interestsLabel.font = .boldSystemFont(ofSize: UIFont.sizes.normal);
    }

    func setupChildView() {
        tagsCollectionViewController = TagsCollectionViewController.init(tags: self.tags, collectionViewLayout: CollectionViewLeftAlignFlowLayout())
        self.addChild(tagsCollectionViewController);
        tagsCollectionViewController.view.frame = self.containerView.bounds;
        containerView.addSubview(tagsCollectionViewController.view);
        tagsCollectionViewController.didMove(toParent: self);
    }
    
    @objc private func doneButtonTapped() {
        tagsUpdated?(tags);
        //When this screen is shown from AboutMe in Profile Screen, dismiss() needs to be called
        if (navigationController?.viewControllers.count ?? 2) <= 1 {
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true);
        }
    }
    
   private var doneButton: UIButton = {
        let button = UIButton(frame: CGRect.init(x: 0, y: 0, width: 45, height: 30));
        
        button.setTitleColor(ColorName.accent.color, for: .normal);
        button.titleLabel?.font = UIFont.appMedium.withSize(UIFont.sizes.small);
        button.makeCornerRound(cornerRadius: 3);
        
    button.setTitle(L10n.Common.done, for: .normal);
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside);
        
        return button;
    }()
}

extension ProfileEditTagsViewController : TagsInputViewDelegate {
    
    /// Following two functions are required for accessoryView
    override var inputAccessoryView: UIView? {
        get{
            return tagsInputView;
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true;
    }
    
    
    func tags(_ tagsInputView: TagsInputView) -> [String] {
        return tagsCollectionViewController.tags as! [String];
    }
    
    func suggestedTag(_ tagsInputView: TagsInputView, tag: String) {
        tagsCollectionViewController.append(tag: tag);
    }
}
