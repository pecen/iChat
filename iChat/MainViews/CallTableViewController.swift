//
//  CallTableViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-19.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import ProgressHUD
import FirebaseFirestore

class CallTableViewController: UITableViewController, UISearchResultsUpdating {
    var allCalls: [CallClass] = []
    var filteredCalls: [CallClass] = []
    var callListener: ListenerRegistration!

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadCalls()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCalls.count
        }
        
        return allCalls.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CallTableViewCell
        
        var call: CallClass!

        if searchController.isActive && searchController.searchBar.text != "" {
            call = filteredCalls[indexPath.row]
        }
        else {
            call = allCalls[indexPath.row]
        }
        
        cell.generateCellWith(call: call)
        
        return cell
    }
    
    // MARK: - TableViewDelegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            var tmpCall: CallClass!
            
            if searchController.isActive && searchController.searchBar.text != "" {
                tmpCall = filteredCalls[indexPath.row]
                filteredCalls.remove(at: indexPath.row)
            }
            else {
                tmpCall = allCalls[indexPath.row]
                allCalls.remove(at: indexPath.row)
            }
            
            tmpCall.deleteCall()
            tableView.reloadData()
        }
    }
    
    // MARK: - LoadCalls
    
    func loadCalls() {
        callListener = reference(.Call).document(FUser.currentId()).collection(FUser.currentId()).order(by: kDATE, descending: true).limit(to: 20).addSnapshotListener({ (snapshot, error) in
            self.allCalls = []
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                let sortedDictionary = dictionaryFromSnapshots(snapshots: snapshot.documents)
                
                for callDictionary in sortedDictionary {
                    let call = CallClass(_dictionary: callDictionary)
                    
                    self.allCalls.append(call)
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    // MARK: - SearchController

    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }

    func filteredContentForSearchText(searchText: String, scope: String = "All") {
        filteredCalls = allCalls.filter({ (call) -> Bool in
            var callerName: String!
            
            if call.callerId == FUser.currentId() {
                callerName = call.withUserFullName
            }
            else {
                callerName = call.callerFullName
            }
            
            return callerName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}
