//
//  PushNotifications.swift
//  iChat
//
//  Created by Peter Centellini on 2019-10-17.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import OneSignal

func sendPushNotification(memberToPush: [String], message: String) {
    let updatedMembers = removeCurrentUserFromMembersArray(members: memberToPush)

    getMembersToPush(members: updatedMembers) { (userPushIds) in
        let currentUser = FUser.currentUser()!
        
        OneSignal.postNotification(["contents" : ["en" : "\(currentUser.firstname) \n(message)"], "ios_badgeType" : "Increase", "ios_badgeCount" : "1", "include_player_ids" : userPushIds])
    }
}

func removeCurrentUserFromMembersArray(members: [String]) -> [String] {
    var updatedMembers : [String] = []
    
    for memberId in members {
        if memberId != FUser.currentId() {
            updatedMembers.append(memberId)
        }
    }
    
    return updatedMembers
}

func getMembersToPush(members: [String], completion: @escaping (_ usersArray: [String]) -> Void) {
    var pushIds: [String] = []
    var count = 0
    
    for memberId in members {
        reference(.User).document(memberId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else { completion(pushIds); return }
            
            if snapshot.exists {
                let userDict = snapshot.data() as! NSDictionary
                let fUser = FUser.init(_dictionary: userDict)
                
                pushIds.append(fUser.pushId!)
                count += 1
                
                if members.count == count {
                    completion(pushIds)
                }
            }
            else {
                completion(pushIds)
            }
        }
    }
}
