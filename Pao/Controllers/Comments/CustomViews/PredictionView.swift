//
//  PredictionView.swift
//  Pao
//
//  Created by Waseem Ahmed on 05/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class PredictionView: UIView {
    
    @IBOutlet var predictionLabels: [UILabel]!
    
    private var keyword: TagKeyword?
    
    var callback: ((_ keyword:TagKeyword?, _ mention: String) -> Void)?
    
    var predictions = [String]();
    
    override func awakeFromNib() {
        super.awakeFromNib();
        
        applyStyle();
        setGestures();
    }
    
    func tagForPrediction(keyword: TagKeyword?) {
        self.keyword = keyword;
        clearPredictions();
        
        guard keyword != nil, keyword?.keyword != nil else { return; }
        
        let word = keyword!.keyword!.replacingOccurrences(of: "@", with: "");
        
        guard word.count > 0 else {return}
        
        showPredictions(predictions: filterPredictions(keyword: keyword!));
    }
    
    func clearPredictions() {
        for label in predictionLabels {
            setPredictionText(label: label, text: nil);
        }
    }
    
    @objc func tapHandler(gesture: UIGestureRecognizer) {
        guard let label = gesture.view as? UILabel, label.text != nil else {return;}
        
        callback?(keyword,label.text!.replacingOccurrences(of: "\"", with: ""));
    }
    
    //Mark - Private functions
    private func applyStyle() {
        backgroundColor = ColorName.background.color
        
        predictionLabels.forEach({
            $0.font = UIFont.appNormal.withSize(UIFont.sizes.normal);
            $0.textAlignment = .center;
        })
    }
    
    private func setGestures() {
        predictionLabels.forEach({
            let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(tapHandler(gesture:)));
            $0.addGestureRecognizer(tapGesture);
            $0.isUserInteractionEnabled = true;
        })
    }
    
    private func showPredictions(predictions: [String]) {
        for (index, value) in predictions.enumerated() where index < 3 {
              setPredictionText(label: predictionLabels[index], text:  "\(value)");
        }
    }
    
    private func setPredictionText(label: UILabel, text: String?) {
        label.text = text;
        if let scrollView = label.superview as? UIScrollView {
            let widthContent = label.sizeThatFits(CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: scrollView.bounds.height)).width + 2;
            scrollView.contentSize = CGSize.init(width: widthContent < scrollView.bounds.width ? scrollView.bounds.width : widthContent, height: scrollView.bounds.height);
        }
    }
}

extension PredictionView {
    private func filterPredictions(keyword: TagKeyword) -> [String]{
       return predictions.filter({$0.lowercased().contains(keyword.keyword!.lowercased())})
    }
}

