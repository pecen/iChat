//
//  GroupMemberCollectionViewCell.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-08.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit

protocol GroupMemberCollectionViewCellDelegate {
    func didClickDeleteButton(indexPath: IndexPath)
}

class GroupMemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var indexPath : IndexPath!
    var delegate : GroupMemberCollectionViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
//        if avatarImageView != nil {
//            tapGestureRecognizer.addTarget(self, action: #selector(self.avatarTap))
//
//            avatarImageView.isUserInteractionEnabled = true
//            avatarImageView.addGestureRecognizer(tapGestureRecognizer)
//        }
    }

    func generateCell(user: FUser, indexPath: IndexPath) {
        self.indexPath = indexPath
        
        nameLabel.text = user.firstname
        
        if user.avatar != "" {
            imageFromData(pictureData: user.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        delegate!.didClickDeleteButton(indexPath: indexPath)
    }
    
}
