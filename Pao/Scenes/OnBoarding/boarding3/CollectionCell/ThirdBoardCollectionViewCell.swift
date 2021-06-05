//
//  ThirdBoardCollectionViewCell.swift
//  Pao
//
//  Created by Waseem Ahmed on 16/11/2018.
//  Copyright © 2018 Exelia. All rights reserved.
//

import UIKit

class ThirdBoardCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = UIColor.green;
    }

    func set(image: UIImage?) {
        self.imageView.image = image;
         makeCornerRound();
    }
}
