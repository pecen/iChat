//
//  IncomingMessages.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-30.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    var collectionView: JSQMessagesCollectionView
    
    init(collectionView_: JSQMessagesCollectionView) {
        collectionView = collectionView_
    }
    
    // MARK: - CreateMessage
    
    func createMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage? {
        var msg: JSQMessage?
        
        let type = messageDictionary[kTYPE] as! String
        
        switch type {
        case kTEXT:
            // create text msg
            msg = createTextMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        case kPICTURE:
            // create picture msg
            print("create picture message")
        case kVIDEO:
            // create video msg
            print("create video message")
        case kAUDIO:
            // create audio msg
            print("create audio message")
        case kLOCATION:
            // create location msg
            print("create location message")
        default:
            print("Unknown message type")
        }
        
        if msg != nil {
            return msg
        }
        else {
            return nil
        }
    }
    
    // MARK: - Create Message types
    
    func createTextMessage(messageDictionary: NSDictionary, chatRoomId: String) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        
        var date: Date!
        
        if let created = messageDictionary[kDATE] {
            if (created as! String).count != 14 {
                date = Date()
            }
            else {
                date = dateFormatter().date(from: created as! String)
            }
        }
        else {
            date = Date()
        }
        
        let text = messageDictionary[kMESSAGE] as! String
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, text: text)
    }
}
