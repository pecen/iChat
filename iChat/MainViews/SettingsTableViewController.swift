//
//  SettingsTableViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-23.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var showAvatarStatusSwitch: UISwitch!
    
    @IBOutlet weak var versionLabel: UILabel!
    
    let userDefaults = UserDefaults.standard
    
    var avatarSwitchStatus = false
    var firstLoad: Bool?
    
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil {
            setupUI()
            loadUserDefaults()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.tableFooterView = UIView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 5
        }

        return 2
    }
    
    // MARK: - TableViewDelegate
    
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

    // MARK: - IBActions
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
        let text = "Hey! Let's chat on iChat \(kAPPURL)"
        let objectsToShare : [Any] = [text]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = self.view
        activityViewController.setValue("Let's chat on iChat", forKey: "subject")
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func cleanCacheButtonPressed(_ sender: Any) {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: getDocumentsURL().path)
            
            for file in files {
                try FileManager.default.removeItem(atPath: "\(getDocumentsURL().path)/\(file)")
            }
            ProgressHUD.showError("Cache cleaned")
        }
        catch {
            ProgressHUD.showError("Couldn't clean Media files")
        }
    }
    
    @IBAction func showAvatarSwitchValueChanged(_ sender: UISwitch) {
        avatarSwitchStatus = sender.isOn
        
        saveUserDefaults()
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        FUser.logOutCurrentUser { (success) in
            if success {
                // show login view
                self.showLoginView()
            }
        }
    }
    
    func showLoginView() {
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcome")
        
        self.present(mainView, animated: true, completion: nil)
    }

    @IBAction func deleteAccountButtonPressed(_ sender: Any) {
        let optionMenu = UIAlertController(title: "Delete Account", message: "Are you sure you want to delete the account?", preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (alert) in
            // delete the user
            self.deleteUser()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (alert) in
            // cancel the action
        }
        
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(cancelAction)
        
        // for iPad not to crashs
        if ( UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                
                currentPopoverpresentioncontroller.sourceView = deleteButtonOutlet
                currentPopoverpresentioncontroller.sourceRect = deleteButtonOutlet.bounds
                
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
        else{
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    // MARK: - SetupUI
    
    func setupUI() {
        let currentUser = FUser.currentUser()!
        
        fullNameLabel.text = currentUser.fullname
        
        if currentUser.avatar != "" {
            imageFromData(pictureData: currentUser.avatar) { (avatarImage) in
                if avatarImage != nil {
                    self.avatarImageView.image = avatarImage!.circleMasked
                }
            }
        }
        
        // set app version
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
    }
    
    // MARK: - Delete user
    
    func deleteUser() {
        // delete user locally
        userDefaults.removeObject(forKey: kPUSHID)
        userDefaults.removeObject(forKey: kCURRENTUSER)
        userDefaults.synchronize()
        
        // delete from Firebase
        reference(.User).document(FUser.currentId()).delete()
        
        FUser.deleteUser { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError("Couldn't delete user")
                }
                
                return
            }
            
            self.showLoginView()
        }
    }

    // MARK: - UserDefaults
    
    func saveUserDefaults() {
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults() {
        firstLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        showAvatarStatusSwitch.isOn = avatarSwitchStatus
    }
    
}
