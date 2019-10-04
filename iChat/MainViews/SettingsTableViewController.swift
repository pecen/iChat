//
//  SettingsTableViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-23.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    
    @IBOutlet weak var deleteButtonOutlet: UIButton!
    @IBOutlet weak var showAvatarStatusSwitch: UISwitch!
    
    override func viewDidAppear(_ animated: Bool) {
        if FUser.currentUser() != nil {
            setupUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 {
            return 5
        }

        return 2
    }


    // MARK: IBActions
    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
    }
    @IBAction func cleanCacheButtonPressed(_ sender: Any) {
    }
    @IBAction func showAvatarSwitchValueChanged(_ sender: Any) {
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
    }
    
    // set app version
}
