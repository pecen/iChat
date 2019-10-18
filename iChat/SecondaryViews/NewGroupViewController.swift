//
//  NewGroupViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-08.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class NewGroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GroupMemberCollectionViewCellDelegate, ImagePickerDelegate {
    @IBOutlet weak var editAvatarButtonOutlet: UIButton!
    @IBOutlet weak var groupIconImageView: UIImageView!
    @IBOutlet weak var groupSubjectTextField: UITextField!
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var iconTapGesture: UITapGestureRecognizer!
    
    var memberIds: [String] = []
    var allMembers: [FUser] = []
    var groupIcon: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        navigationItem.largeTitleDisplayMode = .never
        groupIconImageView.isUserInteractionEnabled = true
        groupIconImageView.addGestureRecognizer(iconTapGesture)
        
        updateParticipantsLabel()
    }
    
    // MARK: - CollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allMembers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! GroupMemberCollectionViewCell
        
        cell.delegate = self
        cell.generateCell(user: allMembers[indexPath.row], indexPath: indexPath)
        
        return cell
    }
    
    // MARK: - IBActions
    
    @IBAction func groupIconTapped(_ sender: Any) {
        showIconOptions()
    }
    
    @IBAction func editIconButtonPressed(_ sender: Any) {
        showIconOptions()
    }
    
    @objc func createButtonPressed(_ sender: Any) {
        if groupSubjectTextField.text != "" {
            memberIds.append(FUser.currentId())
            
            // converts our data to a string
            let avatarData = UIImage(named: "groupIcon")!.jpegData(compressionQuality: 0.7)!
            var avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            if groupIcon != nil {
                let avatarData = groupIcon!.jpegData(compressionQuality: 0.4)!
                avatar = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            }
            
            let groupId = UUID().uuidString
            let group = Group(groupId: groupId, subject: groupSubjectTextField.text!, ownerId: FUser.currentId(), members: memberIds, avatar: avatar)
            
            group.saveGroup()
            
            // create group Recent
            
            startGroupChat(group: group)
            
            // go to chat view
            
            let chatVC = ChatViewController()
            
            chatVC.titleName = group.groupDict[kNAME] as? String
            chatVC.memberIds = group.groupDict[kMEMBERS] as? [String]
            chatVC.membersToPush = group.groupDict[kMEMBERS] as? [String]
            chatVC.chatRoomId = groupId
            chatVC.isGroup = true
            chatVC.hidesBottomBarWhenPushed = true
            
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
        else {
            ProgressHUD.showError("Subject is required")
        }
    }
    
    // MARK: - GroupMemberCollectionViewDelegate
    
    func didClickDeleteButton(indexPath: IndexPath) {
        allMembers.remove(at: indexPath.row)
        memberIds.remove(at: indexPath.row)
        
        collectionView.reloadData()
        updateParticipantsLabel()
    }
    
    // MARK: - Helper functions
    
    func showIconOptions() {
        let optionMenu = UIAlertController(title: "Choose group Icon", message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take/Choose Photo", style: .default) { (alert) in
            let imagePicker = ImagePickerController()
            imagePicker.delegate = self
            imagePicker.imageLimit = 1
            
            self.present(imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            
        }
        
        if groupIcon != nil {
            let resetAction = UIAlertAction(title: "Reset", style: .default) { (alert) in
                self.groupIcon = nil
                self.groupIconImageView.image = UIImage(named: "cameraIcon")
                self.editAvatarButtonOutlet.isHidden = true
            }
            
            optionMenu.addAction(resetAction)
        }
        
        optionMenu.addAction(takePhotoAction)
        optionMenu.addAction(cancelAction)
        
        if ( UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                
                currentPopoverpresentioncontroller.sourceView = editAvatarButtonOutlet
                currentPopoverpresentioncontroller.sourceRect = editAvatarButtonOutlet.bounds
                
                
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
        else {
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func updateParticipantsLabel() {
        participantsLabel.text = "PARTICIPANTS: \(allMembers.count)"
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Create", style: .plain, target: self, action: #selector(self.createButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = allMembers.count > 0
    }
    
    // MARK: - ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.groupIcon = images.first!
            self.groupIconImageView.image = self.groupIcon!.circleMasked
            self.editAvatarButtonOutlet.isHidden = false
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
