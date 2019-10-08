//
//  BackgroundCollectionViewCell.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-07.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit

class BackgroundCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
    
}
