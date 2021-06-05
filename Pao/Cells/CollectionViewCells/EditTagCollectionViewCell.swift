//
//  EditTagCollectionViewCell.swift
//  Pao
//
//  Created by Exelia Technologies on 07/09/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class EditTagCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    private var delete: ((String) -> Void)?;
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        
        layer.cornerRadius = 7.5;
        backgroundColor = UIColor.white.withAlphaComponent(0.05);
    }
    
    func set(tag: String, delete: @escaping (String) -> Void) {
        tagLabel.text = tag;
        self.delete = delete;
    }
    
    @IBAction func deleteButtonTouchedUpInside(_ sender: UIButton) {
        delete?(tagLabel.text!);
        
        NotificationCenter.default.post(name: .tagRemoved, object: tagLabel.text!);
    }
}
