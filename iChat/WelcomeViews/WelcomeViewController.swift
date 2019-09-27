//
//  WelcomeViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-18.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var repeatPwdTextField: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: IBActions
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        dismissKeyboard()
        
        if emailTextField.text != "" && pwdTextField.text != "" {
            loginUser()
        }
        else {
            ProgressHUD.showError("Email and Password is missing!")
        }
    }

    @IBAction func registerButtonPressed(_ sender: Any) {
        dismissKeyboard()

        if emailTextField.text != "" && pwdTextField.text != "" && repeatPwdTextField.text != "" {
            if pwdTextField.text == repeatPwdTextField.text {
                registerUser()
            }
            else {
                ProgressHUD.showError("Passwords don't match!")
            }
        }
        else {
            ProgressHUD.showError("All fields are required!")
        }
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
        dismissKeyboard()
    }
    
    //MARK: Helper functions
    
    func loginUser() {
        ProgressHUD.show("Logging in...")
        
        FUser.loginUserWith(email: emailTextField.text!, password: pwdTextField.text!) {
            (error) in
            
            if error != nil {
                ProgressHUD.showError(error!.localizedDescription)
                return
            }
            
            self.goToApp()
        }
    }
    
    func registerUser() {
        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)
        cleanTextFields()
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    func cleanTextFields(){
        emailTextField.text = ""
        pwdTextField.text = ""
        repeatPwdTextField.text = ""
    }
    
    func goToApp() {
        ProgressHUD.dismiss()
        
        cleanTextFields()
        dismissKeyboard()
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])

        let mainView = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "mainApplication") as!
            UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "welcomeToFinishReg" {
            let vc = segue.destination as! FinishRegistrationViewController
            vc.email = emailTextField.text!
            vc.pwd = pwdTextField.text!            
        }
    }
}
