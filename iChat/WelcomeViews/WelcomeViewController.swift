//
//  WelcomeViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-18.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD

@IBDesignable
class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //MARK: IBActions
    
    
    //MARK: Helper functions
    
//    func loginUser() {
//        ProgressHUD.show("Logging in...")
//        
//        FUser.loginUserWith(email: emailTextField.text!, password: pwdTextField.text!) {
//            (error) in
//            
//            if error != nil {
//                ProgressHUD.showError(error!.localizedDescription)
//                return
//            }
//            
//            self.goToApp()
//        }
//    }
    
//    func registerUser() {
//        performSegue(withIdentifier: "welcomeToFinishReg", sender: self)
//        cleanTextFields()
//        dismissKeyboard(vc: self)
//    }
//    
//    func cleanTextFields(){
//        emailTextField.text = ""
//        pwdTextField.text = ""
//        repeatPwdTextField.text = ""
//    }
    
//    func goToApp() {
//        ProgressHUD.dismiss()
//        
//        cleanTextFields()
//        dismissKeyboard()
//        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID : FUser.currentId()])
//
//        let mainView = UIStoryboard.init(name: "Main", bundle: nil)
//            .instantiateViewController(withIdentifier: "mainApplication") as!
//            UITabBarController
//        
//        self.present(mainView, animated: true, completion: nil)
//    }
    
}
