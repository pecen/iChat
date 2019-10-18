//
//  FinishRegistrationViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-19.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD
import ImagePicker

class FinishRegistrationViewController: UIViewController, ImagePickerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var email : String!
    var pwd : String!
    var avatarImg : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        avatarImageView.isUserInteractionEnabled = true
    }
    

    //MARK: IBActions
    
    @IBAction func avatarImageTap(_ sender: Any) {
        let imagePickerController = ImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.imageLimit = 1
        
        present(imagePickerController, animated: true, completion: nil)
        dismissKeyboard()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        cleanTextFields()
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        dismissKeyboard()
        ProgressHUD.show("Registering...")
        
        if nameTextField.text != "" && surnameTextField.text != "" && cityTextField.text != ""
            && countryTextField.text != ""  && phoneTextField.text != "" {
            
            FUser.registerUserWith(email: email!, password: pwd!, firstName: nameTextField.text!, lastName: surnameTextField.text!) { (error) in
                if error != nil {
                    ProgressHUD.dismiss()
                    ProgressHUD.showError(error!.localizedDescription)
                    return
                }
                
                self.registerUser()
            }
        }
        else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    //MARK: Helpers
    func registerUser() {
        let fullName = nameTextField.text! + " " + surnameTextField.text!
        
        var tempDict : Dictionary = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!,
                                     kFULLNAME : fullName, kCOUNTRY : countryTextField.text!,
                                     kCITY : cityTextField.text!, kPHONE : phoneTextField.text!] as [String : Any]
        
        if avatarImg == nil {
            imageFromInitials(firstName: nameTextField.text!, lastName: surnameTextField.text!) { (avatarInitials) in
                let avatar = avatarInitials.jpegData(compressionQuality: 0.7)
                let avatarStr = avatar!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                
                tempDict[kAVATAR] = avatarStr
            }
            
            self.finishRegistration(withValues: tempDict)
        }
        else {
            let avatarData = avatarImg?.jpegData(compressionQuality: 0.5)
            let avatarStr = avatarData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            
            tempDict[kAVATAR] = avatarStr

            self.finishRegistration(withValues: tempDict)
        }
    }
    
    func finishRegistration(withValues: [String : Any]) {
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                    print(error!.localizedDescription)
                }
                
                return
            }
            
            ProgressHUD.dismiss()
            self.goToApp()            
        }
    }
    
    func goToApp() {
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])

        let mainView = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "mainApplication") as!
            UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields(){
        nameTextField.text = ""
        surnameTextField.text = ""
        cityTextField.text = ""
        countryTextField.text = ""
        phoneTextField.text = ""
    }
    
    // MARK: - ImagePickerDelegatee

    func wrapperDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func doneButtonDidPress(_ imagePicker: ImagePickerController, images: [UIImage]) {
        if images.count > 0 {
            self.avatarImg = images.first!
            self.avatarImageView.image = self.avatarImg?.circleMasked
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelButtonDidPress(_ imagePicker: ImagePickerController) {
        self.dismiss(animated: true, completion: nil)

    }
}
