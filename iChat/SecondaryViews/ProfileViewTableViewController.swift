//
//  ProfileViewTableViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-26.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD

class ProfileViewTableViewController: UITableViewController {
    
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    @IBOutlet weak var msgButtonOutlet: UIButton!
    @IBOutlet weak var callButtonOutlet: UIButton!
    
    @IBOutlet weak var blockButtonOutlet: UIButton!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var user: FUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // MARK: - IBActions

    @IBAction func callButtonPressed(_ sender: Any) {
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        if !checkBlockedStatus(withUser: user!) {
            let chatVC = ChatViewController()
            
            chatVC.titleName = user!.firstname
            chatVC.membersToPush = [FUser.currentId(), user!.objectId]
            chatVC.memberIds = [FUser.currentId(), user!.objectId]
            chatVC.chatRoomId = startPrivateChat(user1: FUser.currentUser()!, user2: user!)
            chatVC.isGroup = false
            chatVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        else {
            ProgressHUD.showError("This user is not available for chat!")
        }
    
    }
    
    @IBAction func blockUserButtonPressed(_ sender: Any) {
        var currentBlockedIds = FUser.currentUser()!.blockedUsers
        
        if currentBlockedIds.contains(user!.objectId) {
            currentBlockedIds.remove(at: currentBlockedIds.firstIndex(of: user!.objectId)!)
        }
        else {
            currentBlockedIds.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID : currentBlockedIds]) { (error) in
            if error != nil {
                print("error updating user: \(error!.localizedDescription)")
                
                return
            }
            
            self.updateBlockStatus()
        }
        
        blockUser(userToBlock: user!)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        
        return 30
    }
    
    // MARK: - My implementation - not from the course
    
    
    // End of my implementation
    
    // MARK: - Setup UI
    
    func setupUI() {
        if user != nil {
            self.title = "Profile"
            
            fullNameLabel.text = user!.fullname
            phoneNumberLabel.text = user!.phoneNumber
            
            updateBlockStatus()
            
            imageFromData(pictureData: user!.avatar) { (avatarImg) in
                if avatarImg != nil {
                    self.avatarImageView.image = avatarImg!.circleMasked
                }
            }
        }
    }

    func updateBlockStatus() {
        if user!.objectId != FUser.currentId() {
            blockButtonOutlet.isHidden = false
            msgButtonOutlet.isHidden = false
            callButtonOutlet.isHidden = false
        }
        else {
            blockButtonOutlet.isHidden = true
            msgButtonOutlet.isHidden = true
            callButtonOutlet.isHidden = true
        }
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButtonOutlet.setTitle("Unblock User", for: .normal)
        }
        else {
            blockButtonOutlet.setTitle("Block User", for: .normal)
        }
    }
}
