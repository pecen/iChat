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
    
    @IBOutlet weak var currentPwdTextField: UITextField!
    @IBOutlet weak var newPwdTextField: UITextField!
    @IBOutlet weak var repeatPwdTextField: UITextField!
    
    var avatarImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
            return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 7
        default:
            return 4
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Change Password"
        }
        
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
    
    @IBAction func changePwdButtonPressed(_ sender: Any) {
        dismissKeyboard(vc: self)
        
        if currentPwdTextField.text != "" && newPwdTextField.text != "" && repeatPwdTextField.text != "" {
            if newPwdTextField.text == repeatPwdTextField.text {
                changePassword()
            }
            else {
                ProgressHUD.showError("New passwords don't match!")
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
    
    // MARK: - Change Password
    
    func changePassword() {
        ProgressHUD.show("Changing password...")
        
        FUser.validateUserPwd(password: currentPwdTextField.text!) { (error) in
            if error != nil {
                //print("Error caught: \(error!.localizedDescription)")
                ProgressHUD.showError(error?.localizedDescription)
            }
            else {
                FUser.changeUserPwd(password: self.newPwdTextField.text!) { (error) in
                    if error != nil {
                        // an error happened
                        ProgressHUD.showError(error?.localizedDescription)
                        self.clearPwdTextFields()
                        
                        return
                    }
                    self.clearPwdTextFields()

                    ProgressHUD.showSuccess("Password changed!")
                }
            }
        }

//        ProgressHUD.dismiss()
    }
    
    // MARK: - Helper functions
    
    func clearPwdTextFields() {
        currentPwdTextField.text = ""
        newPwdTextField.text = ""
        repeatPwdTextField.text = ""
    }
}
