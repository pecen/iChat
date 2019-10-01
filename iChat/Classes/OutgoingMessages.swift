//
//  OutgoingMessages.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-30.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation

class OutgoingMessage {
    let msgDictionary: NSMutableDictionary
    
    // MARK: - Initializers
    
    // text message
    
    init(message: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        msgDictionary = NSMutableDictionary(objects: [message, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // picture message
    
    init(message: String, pictureLink: String, senderId: String, senderName: String, date: Date, status: String, type: String) {
        msgDictionary = NSMutableDictionary(objects: [message, pictureLink, senderId, senderName, dateFormatter().string(from: date), status, type], forKeys: [kMESSAGE as NSCopying, kPICTURE as NSCopying, kSENDERID as NSCopying, kSENDERNAME as NSCopying, kDATE as NSCopying, kSTATUS as NSCopying, kTYPE as NSCopying])
    }
    
    // MARK: - SendMessage
    
    func sendMsg(chatRoomId: String, messageDict: NSMutableDictionary, memberIds: [String], membersToPush: [String]) {
        let msgId = UUID().uuidString
        
        msgDictionary[kMESSAGEID] = msgId
        
        for memberId in memberIds {
            reference(.Message).document(memberId).collection(chatRoomId).document(msgId).setData(messageDict as! [String : Any])
        }
        
        // update recent chat
        
        // send push notifications
    }
}
