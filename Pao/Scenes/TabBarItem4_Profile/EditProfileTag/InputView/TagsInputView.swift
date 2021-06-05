//
//  TagsInputView.swift
//  Pao
//
//  Created by Waseem Ahmed on 23/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class TagsInputView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var suggestTagCollectionView: TagCollectionView!
    
    let defaultPredictions = [
        "rooftop bars",
        "healthy",
        "hiking",
        "art/culture",
        "brunch",
        "views",
        "budget",
        "karaoke",
        "fitness",
        "pizza",
        "luxury",
        "outdoors",
        "clubbing",
        "camping"];
    
    /// Predictions which are displayed in the collectionView tab.
    var predictions = [String]()
    
    /// default-predictions by removing the selected tags
    var filteredPredictions = [String]()
    
    /// predicted words from keyboard
    var keyboardPredictions = [String]()
    
    /// tags which are currently selected by user
    var selectedTags = [String]() {
        didSet{
            populateFilteredPredictions();
            reloadSuggestions();
        }
    }
    
    /// maximum characters allowed for a tag
     private let maxLength = 30

    private let textChecker = UITextChecker()
    
    var delegate:TagsInputViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame);
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        NotificationCenter.default.removeObserver(self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        comonInit();
    }
    
    func comonInit() {
        predictions = self.defaultPredictions;
        filteredPredictions = self.defaultPredictions;
        
        setupChildViews();
        setupInputTextField();
        setupSuggestTagCollection();
        
        heightAnchor.constraint(equalToConstant: 56).isActive = true;
        
        NotificationCenter.default.addObserver(self, selector: #selector(tagRemoved(_:)), name: .tagRemoved, object: nil);
    }
    
    func setupChildViews() {
        backgroundColor = ColorName.background.color;
        containerView.backgroundColor = UIColor.white.withAlphaComponent(0.1);
    }
    
    private func setupSuggestTagCollection() {
        suggestTagCollectionView.delegate = self;
        suggestTagCollectionView.allowsSelection = true;
       (suggestTagCollectionView.collectionViewLayout as! UICollectionViewFlowLayout).estimatedItemSize = CGSize(width: 80.0, height: 30.0);
        suggestTagCollectionView.tags = NSMutableArray(array: self.predictions as [String]);
        resizeHeight(isEditting:  false);
    }
    
    private func setupInputTextField() {
        inputTextField.set(placeholderColor: .lightGray);
        inputTextField.layer.cornerRadius = 5.0;
        inputTextField.layer.borderColor = UIColor.white.cgColor;
        inputTextField.layer.borderWidth = 1.0;
        inputTextField.returnKeyType = .done;
        inputTextField.autocorrectionType = .no;
        inputTextField.delegate = self;
        inputTextField.addTarget(self, action: #selector(editingChanged), for: .editingChanged);
    }
    
    @objc private func editingChanged() {
        guard let text = inputTextField.text else { return; }
        
        let language = UITextChecker.availableLanguages.first!;
        let wordRange = NSRange(0..<text.count);
        let guesses = textChecker.guesses(forWordRange: wordRange, in: text.trim, language: language);
        let completions = textChecker.completions(forPartialWordRange: wordRange, in: text.trim, language: language);

        var suggestions: [String] = [];
        if let guesses = guesses { suggestions.append(contentsOf: guesses); }
        if let completions = completions { suggestions.append(contentsOf: completions); }
        suggestions = Array(NSOrderedSet(array: suggestions)) as! [String];
    
        if suggestions.isEmpty, text.trim.isNotEmpty { suggestions.append(text.trim) }
        
        keyboardPredictions = suggestions;
        reloadSuggestions();
    }

    @objc func tagRemoved(_ notification: Notification) {
        if let tag = notification.object as? String {
            if let index = selectedTags.firstIndex(of: tag) { selectedTags.remove(at: index) }
        }
    }
    
    func checkSuggestions(tagSelectedFromList: Bool = false) {
        if let newTag = inputTextField.text, !newTag.isEmptyOrWhitespace,
            let delegate = self.delegate {
            let tags = delegate.tags(self);
            var containsTag = false;
            for tagIndex in 0..<tags.count {
                let tag = tags[tagIndex];
                containsTag = (tag.caseInsensitiveCompare(newTag) == .orderedSame);
                if (containsTag) { break; }
            }
        
            if (!containsTag) {

                delegate.suggestedTag(self, tag: newTag);
                
                if !selectedTags.contains(newTag) { selectedTags.append(newTag) };
            }
            inputTextField.text = String.empty;
            keyboardPredictions.removeAll()
            reloadSuggestions()
        }
    }
    
    private func populateFilteredPredictions() {
        filteredPredictions = defaultPredictions.reduce(into: Array<String>()) { (predictions, prediction) in
            if (selectedTags.contains(prediction)) { return; }
            predictions.append(prediction);
        }
    }
    
   private func reloadSuggestions() {
        self.predictions = keyboardPredictions + filteredPredictions;
        self.predictions = Array(NSOrderedSet(array: self.predictions)) as! [String];
        suggestTagCollectionView.tags = NSMutableArray(array: self.predictions as [String]);
    }
}

extension TagsInputView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = predictions[indexPath.row].widthOfString(usingFont:  UIFont.app) + 24; // 24: padding horizontal
        return  CGSize.init(width: width, height: 30);
    }
}

extension TagsInputView: UITextFieldDelegate {
    @discardableResult
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        checkSuggestions();
        return true;
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        resizeHeight(isEditting: true);
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resizeHeight(isEditting: false);
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           let currentString: NSString = textField.text! as NSString
           let newString: NSString =
               currentString.replacingCharacters(in: range, with: string) as NSString
           return newString.length <= maxLength
    }
}

protocol TagsInputViewDelegate {
    func suggestedTag(_ tagsInputView: TagsInputView, tag: String);
    func tags(_ tagsInputView: TagsInputView) -> [String];
}

extension TagsInputView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        inputTextField.text = suggestTagCollectionView.tags[indexPath.item] as? String;
        checkSuggestions(tagSelectedFromList: true);
    }
    
    private func resizeHeight(isEditting: Bool = true) {
        self.frame.size.height =   (isEditting ?  40 : 0) + 40 + 16;
        
        for constraint in self.constraints where constraint.firstAttribute == .height {
            constraint.constant = (isEditting ?  40 : 0) + 40 + 16; //(16 is the sum of margins above/below of textfield)
        }
    }
}


extension TagsInputView {
    private func suggestedTags(for keyword: String) -> [String] {
        return predictions.filter({$0.lowercased().contains(keyword.lowercased())})
    }
}
