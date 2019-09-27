//
//  RecentChatTableViewCell.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-27.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit

protocol RecentChatTableViewCellDelegate {
    func didTapAvatarImage(indexPath: IndexPath)
}
class RecentChatTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMsgLabel: UILabel!
    @IBOutlet weak var msgCounterLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var msgCounterBackground: UIView!
    
    var indexPath: IndexPath!
    var delegate: RecentChatTableViewCellDelegate?
    
    let tapGesture = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        msgCounterBackground.layer.cornerRadius = msgCounterBackground.frame.width / 2
        tapGesture.addTarget(self, action: #selector(self.avatarTap))
        avatarImage.isUserInteractionEnabled = true
        avatarImage.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: - Generate Cell
    
    func generateCell(recentChat: NSDictionary, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.nameLabel.text = recentChat[kWITHUSERUSERNAME] as? String
        self.lastMsgLabel.text = recentChat[kLASTMESSAGE] as? String
        // kolla nedanstående rad vid exekvering eftersom jag gjorde lite annorlunda
        self.msgCounterLabel.text = ""
        
        if let avatarString = recentChat[kAVATAR] {
            imageFromData(pictureData: avatarString as! String) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImage.image = avatarImage!.circleMasked
                }
            }
        }
        
        if recentChat[kCOUNTER] as! Int != 0 {
            // kolla nedanstående rad vid exekvering eftersom jag gjorde lite annorlunda
            self.msgCounterLabel.text = recentChat[kCOUNTER] as? String
            self.msgCounterBackground.isHidden = false
            self.msgCounterLabel.isHidden = false
        }
        else {
            self.msgCounterBackground.isHidden = true
            self.msgCounterLabel.isHidden = true
        }
        
        var date: Date!
        
        if let created = recentChat[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }
            else {
                date = dateFormatter().date(from: created as! String)!
            }
        }
        else {
            date = Date()
        }
        
        self.dateLabel.text = timeElapsed(date: date)
    }
    
    @objc func avatarTap() {
        delegate?.didTapAvatarImage(indexPath: indexPath)
    }

}
