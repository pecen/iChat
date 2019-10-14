//
//  InviteUserTableViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-11.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD
import Firebase

class InviteUserTableViewController: UITableViewController, UserTableViewCellDelegate {
    @IBOutlet weak var headerView: UIView!
    var allUsers: [FUser] = []
    var allUsersGrouped = NSDictionary() as! [String : [FUser]]
    var sectionTitleList : [String] = []

    var newMemberIds: [String] = []
    var currentMemberIds: [String] = []
    var group: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Users"
        tableView.tableFooterView = UIView()
        
        self.navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonPressed))]
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        currentMemberIds = group[kMEMBERS] as! [String]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(filter: kCITY)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ProgressHUD.dismiss()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.allUsersGrouped.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitle = self.sectionTitleList[section]
        let users = self.allUsersGrouped[sectionTitle]
        
        return users!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! UserTableViewCell
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGrouped[sectionTitle]
        

        cell.generateCellWith(fUser: users![indexPath.row], indexPath: indexPath)
        
        cell.delegate = self
        
        return cell
    }

    //MARK: TableView Delegate
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleList[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGrouped[sectionTitle]
        let selectedUser = users![indexPath.row]
        
        if currentMemberIds.contains(selectedUser.objectId) {
            ProgressHUD.showError("Already in the group!")
            return
        }
        
        if let cell = tableView.cellForRow(at: indexPath) {
            if cell.accessoryType == .checkmark {
                cell.accessoryType = .none
            }
            else {
                cell.accessoryType = .checkmark
            }
        }
        
        // add/remove users
        
        let selected = newMemberIds.contains(selectedUser.objectId)
        
        if selected {
            // remove
            let objectIndex = newMemberIds.firstIndex(of: selectedUser.objectId)
            newMemberIds.remove(at: objectIndex!)
        }
        else {
            // add to array
            newMemberIds.append(selectedUser.objectId)
        }
        
//        print("new members: \(newMemberIds)")
//        print("current members: \(currentMemberIds)")
        self.navigationItem.rightBarButtonItem?.isEnabled = newMemberIds.count > 0
    }
    
    // MARK: - LoadUsers
    func loadUsers(filter: String) {
        ProgressHUD.show()
        
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapshot, error) in
            self.allUsers = []
            self.sectionTitleList = []
            self.allUsersGrouped = [:]
            
            if error != nil {
                print(error!.localizedDescription)
                ProgressHUD.dismiss()
                
                self.tableView.reloadData()
                return
            }
            
            guard let snapshot = snapshot else {
                ProgressHUD.dismiss()
                return
            }
            
            if !snapshot.isEmpty {
                for userDictionary in snapshot.documents {
                    let userDictionary = userDictionary.data() as NSDictionary
                    let fUser = FUser(_dictionary: userDictionary)
                    
                    if fUser.objectId != FUser.currentId() {
                        self.allUsers.append(fUser)
                    }
                }
                
                // split to groups
                self.splitDataIntoSections()
                //self.tableView.reloadData()
            }
            
            self.tableView.reloadData()
            ProgressHUD.dismiss()
        }
    }

    // MARK: - IBActions
    
    @IBAction func filterSegementValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: kCITY)
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: "")
        default:
            return //loadUsers(filter: "")
        }
    }
    
    @objc func doneButtonPressed() {
        updateGroup(group: group)
    }
    
    // MARK: - UserTableViewCellDelegate
    
    func didTapAvatarImage(indexPath: IndexPath) {
        let profileVC = UIStoryboard.init(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "profileView") as! ProfileViewTableViewController
        let sectionTitle = self.sectionTitleList[indexPath.section]
        let users = self.allUsersGrouped[sectionTitle]
        
        profileVC.user = users![indexPath.row]
        self.navigationController?.pushViewController(profileVC, animated: true)
    }
    
    // MARK: - Helper functions
    
    func updateGroup(group: NSDictionary) {
        let tmpMembers = currentMemberIds + newMemberIds
        let tmpMembersToPush = group[kMEMBERSTOPUSH] as! [String] + newMemberIds
        let withValues = [kMEMBERS : tmpMembers, kMEMBERSTOPUSH : tmpMembersToPush]
        
        Group.updateGroup(groupId: group[kGROUPID] as! String, withValues: withValues)
        
        createRecentsForNewMembers(groupId: group[kGROUPID] as! String, groupName: group[kNAME] as! String, membersToPush: tmpMembersToPush, avatar: group[kAVATAR] as! String)
        updateExistingRecentWithNewValues(chatRoomId: group[kGROUPID] as! String, members: tmpMembers, withValues: withValues)
        goToGroupChat(membersToPush: tmpMembersToPush, members: tmpMembers)
    }
    
    func goToGroupChat(membersToPush: [String], members: [String]) {
        let chatVC = ChatViewController()
        
        chatVC.titleName = group[kNAME] as? String
        chatVC.memberIds = members
        chatVC.membersToPush = membersToPush
        chatVC.chatRoomId = group[kGROUPID] as? String
        chatVC.isGroup = true
        chatVC.hidesBottomBarWhenPushed = true
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    fileprivate func splitDataIntoSections() {
        var sectionTitle: String = ""
        
        for i in 0..<self.allUsers.count {
            let currentUser = self.allUsers[i]
            let firstChar = currentUser.firstname.first!
            let firstCharString = "\(firstChar)"

            if firstCharString != sectionTitle {
                sectionTitle = firstCharString
                
                self.allUsersGrouped[sectionTitle] = []
                
                if !sectionTitleList.contains(sectionTitle) {
                    self.sectionTitleList.append(sectionTitle)
                }
            }
            
            self.allUsersGrouped[firstCharString]?.append(currentUser)
        }
    }
}
