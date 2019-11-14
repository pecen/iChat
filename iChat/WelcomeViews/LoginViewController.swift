//
//  LoginViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-11-12.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: - IBActions

    @IBAction func loginButtonPressed(_ sender: Any) {
        dismissKeyboard(vc: self)
        
        if emailTextField.text != "" && pwdTextField.text != "" {
            loginUser()
        }
        else {
            ProgressHUD.showError("Email and Password is missing!")
        }
    }
    
    @IBAction func backgroundTap(_ sender: Any) {
        dismissKeyboard(vc: self)
    }
    
    // MARK: - Helper functions
    
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

    func goToApp() {
        ProgressHUD.dismiss()
        
        dismissKeyboard(vc: self)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])

        let mainView = UIStoryboard.init(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "mainApplication") as!
            UITabBarController
        
        self.present(mainView, animated: true, completion: nil)
    }
}
