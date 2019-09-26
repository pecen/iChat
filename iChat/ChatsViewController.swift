//
//  ChatsViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-24.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit

class ChatsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    //MARK: IBActions

    @IBAction func CreateNewChatButtonPressed(_ sender: Any) {
        let userVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "usersTableView") as! UsersTableViewController
        
        self.navigationController?.pushViewController(userVC, animated: true)
    }
    
}
