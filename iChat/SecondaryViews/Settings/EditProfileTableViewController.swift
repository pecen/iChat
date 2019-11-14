//
//  EditProfileTableViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-08.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class EditProfileTableViewController: UITableViewController, ImagePickerDelegate {
    @IBOutlet weak var SaveButtonOutlet: UIBarButtonItem!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet var avatarTapGestureRecognizer: UITapGestureRecognizer!
    
    @IBOutlet weak var lastUpdatedLabel: UILabel!
    
    var avatarImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    // MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: Any) {
        if !isDirty() {
            ProgressHUD.showError("Nothing is changed so nothing to save.")
            return
        }
        
        if firstNameTextField.text != "" && lastNameTextField.text != "" && emailTextField.text != "" && phoneTextField.text != "" {
            ProgressHUD.show("Saving...")
            
            // block the save button
            SaveButtonOutlet.isEnabled = false
            
            let fullName = firstNameTextField.text! + " " + lastNameTextField.text!
            let updatedAt = dateFormatter().string(from: Date())
            
            var withValues = [kFIRSTNAME : firstNameTextField.text!, kLASTNAME : lastNameTextField.text!, kFULLNAME : fullName, kEMAIL : emailTextField.text!, kPHONE : phoneTextField.text!, kCITY : cityTextField.text!, kCOUNTRY : countryTextField.text!, kUPDATEDAT : updatedAt]
            
            if avatarImage != nil {
                let avatarData = avatarImage!.jpegData(compressionQuality: 0.4)!
                let avatarString = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                withValues[kAVATAR] = avatarString
            }
            
            // update current user
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        ProgressHUD.showError(error!.localizedDescription)
                        print("couldn't update user: \(error!.localizedDescription)")
                    }
                    
                    self.SaveButtonOutlet.isEnabled = true
                    self.lastUpdatedLabel.text = formatCallTime(date: FUser.currentUser()!.updatedAt)
                    return
                }
                
                ProgressHUD.showSuccess("Saved")
                self.SaveButtonOutlet.isEnabled = true
                self.navigationController?.popViewController(animated: true)
            }
        }
        else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    @IBAction func avatarTap(_ sender: Any) {
        let imagePicker = ImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageLimit = 1
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: - IsDirty
    
    func isDirty() -> Bool {
        let currentUser = FUser.currentUser()
//        var avatarString: String = ""
//
//        if avatarImage != nil {
//            let avatarData = avatarImage!.jpegData(compressionQuality: 0.4)!
//            avatarString = avatarData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
//        }
        
        if firstNameTextField.text == currentUser?.firstname
            && lastNameTextField.text == currentUser?.lastname
            && emailTextField.text == currentUser?.email
            && phoneTextField.text == currentUser?.phoneNumber
            && cityTextField.text == currentUser?.city
            && countryTextField.text == currentUser?.country {
            
            return false
        }
        
        return true
    }
    
    // MARK: - SetupUI
    
    func setupUI() {
        let currentUser = FUser.currentUser()!
        
        avatarImageView.isUserInteractionEnabled = true
        
        firstNameTextField.text = currentUser.firstname
        lastNameTextField.text = currentUser.lastname
        emailTextField.text = currentUser.email
        phoneTextField.text = currentUser.phoneNumber
        cityTextField.text = currentUser.city
        countryTextField.text = currentUser.country
        lastUpdatedLabel.text = "Last updated: \(formatCallTime(date: currentUser.updatedAt))"
        
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
    }

    // MARK: - ImagePickerDelegate
    
    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.avatarImage = images.first!
            self.avatarImageView.image = self.avatarImage!.circleMasked
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
