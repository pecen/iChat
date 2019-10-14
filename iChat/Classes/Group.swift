//
//  Group.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-09.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import FirebaseFirestore

class Group {
    let groupDict: NSMutableDictionary
    
    init(groupId: String, subject: String, ownerId: String, members: [String], avatar: String) {
        groupDict = NSMutableDictionary(objects: [groupId, subject, ownerId, members, members, avatar], forKeys: [kGROUPID as NSCopying, kNAME as NSCopying, kOWNERID as NSCopying, kMEMBERS as NSCopying, kMEMBERSTOPUSH as NSCopying, kAVATAR as NSCopying])
    }
    
    func saveGroup() {
        let date = dateFormatter().string(from: Date())
        
        groupDict[kDATE] = date
        reference(.Group).document(groupDict[kGROUPID] as! String).setData(groupDict as! [String:Any])
    }
    
    class func updateGroup(groupId: String, withValues: [String:Any]) {
        reference(.Group).document(groupId).updateData(withValues)
    }
}
