//
//  RegisterAccountViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-11-12.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD

class RegisterAccountViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pwdTextField: UITextField!
    @IBOutlet weak var repeatPwdTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        dismissKeyboard(vc: self)

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
        dismissKeyboard(vc: self)
    }
    
    // MARK: - Helper functions

    func registerUser() {
        performSegue(withIdentifier: "registerToProfile", sender: self)
        cleanTextFields()
        dismissKeyboard(vc: self)
    }
    
    func cleanTextFields(){
        emailTextField.text = ""
        pwdTextField.text = ""
        repeatPwdTextField.text = ""
    }

    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerToProfile" {
            let vc = segue.destination as! FinishRegistrationViewController
            vc.email = emailTextField.text!
            vc.pwd = pwdTextField.text!
        }
    }
}
