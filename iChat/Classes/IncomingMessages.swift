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
            msg = createPictureMessage(messageDictionary: messageDictionary)
        case kVIDEO:
            // create video msg
            msg = createVideoMessage(messageDictionary: messageDictionary)
        case kAUDIO:
            // create audio msg
            msg = createAudioMessage(messageDictionary: messageDictionary)
        case kLOCATION:
            // create location msg
            msg = createLocationMessage(messageDictionary: messageDictionary)
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
    
    func createPictureMessage(messageDictionary: NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        let date: Date!
        
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
        
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        // download image
        downloadImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            if image != nil {
                mediaItem?.image = image!
                self.collectionView.reloadData()
            }
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createVideoMessage(messageDictionary: NSDictionary) -> JSQMessage {
        let name = messageDictionary[kSENDERNAME] as? String
        let userId = messageDictionary[kSENDERID] as? String
        let date: Date!
        
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
        
        let videoURL = NSURL(fileURLWithPath: messageDictionary[kVIDEO] as! String)
        
        let mediaItem = VideoMessage(withFileURL: videoURL, maskOutgoing: returnOutgoingStatusForUser(senderId: userId!))
        
        // download video
        downloadVideo(videoUrl: messageDictionary[kVIDEO] as! String) { (isReadyToPlay, filename) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: filename))
            
            mediaItem.status = kSUCCESS
            mediaItem.fileURL = url
            
            imageFromData(pictureData: messageDictionary[kPICTURE] as! String) { (image) in
                if image != nil {
                    mediaItem.image = image!
                    self.collectionView.reloadData()
                }
            }
            
            self.collectionView.reloadData()
        }
        
        return JSQMessage(senderId: userId, senderDisplayName: name, date: date, media: mediaItem)
    }
    
    func createAudioMessage(messageDictionary: NSDictionary) -> JSQMessage {
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

        let audioItem = JSQAudioMediaItem(data: nil)
        
        audioItem.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        let audioMsg = JSQMessage(senderId: userId!, senderDisplayName: name!, date: date, media: audioItem)
        
        // download audio

        downloadAudio(audioUrl: messageDictionary[kAUDIO] as! String) { (filename) in
            let url = NSURL(fileURLWithPath: fileInDocumentsDirectory(fileName: filename))
            let audioData = try? Data(contentsOf: url as URL)
            
            audioItem.audioData = audioData
            
            self.collectionView.reloadData()
        }
        
        return audioMsg!
    }

    func createLocationMessage(messageDictionary: NSDictionary) -> JSQMessage {
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
        
        let latitude = messageDictionary[kLATITUDE] as? Double
        let longitude = messageDictionary[kLONGITUDE] as? Double
        let mediaItem = JSQLocationMediaItem(location: nil)
        
        mediaItem?.appliesMediaViewMaskAsOutgoing = returnOutgoingStatusForUser(senderId: userId!)
        
        let location = CLLocation(latitude: latitude!, longitude: longitude!)
        
        mediaItem?.setLocation(location, withCompletionHandler: {
            self.collectionView.reloadData()
        })
        
        return JSQMessage(senderId: userId!, senderDisplayName: name, date: date, media: mediaItem)
    }

    // MARK: - Helper functions
    
    func returnOutgoingStatusForUser(senderId: String) -> Bool {
        return senderId == FUser.currentId()
    }
}
