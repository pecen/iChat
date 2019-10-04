//
//  PicturesCollectionViewCell.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-03.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit

class PicturesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(image: UIImage) {
        self.imageView.image = image
    }
}
