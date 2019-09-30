//
//  ChatViewController.swift
//  iChat
//
//  Created by Peter Centellini on 2019-09-29.
//  Copyright © 2019 Redesajn Interactive Solutions. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore

class ChatViewController: JSQMessagesViewController {
    var outgoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var incomingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    var chatRoomId: String!
    var memberIds: [String]!
    var membersToPush: [String]!
    var titleName: String!
    var messages: [JSQMessage] = []
    var objMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    var initalLoadComplete = false
    
    var maxMsgNumber = 0
    var minMsgNumber = 0
    var loadOld = false
    var loadedMsgsCount = 0
    
    let legitTypes = [kAUDIO, kVIDEO, kTEXT, kLOCATION, kPICTURE]
    
    // Fix for IPhone X and above

    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }

    // end of IPhone X fix

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "Back"), style: .plain, target: self, action: #selector(self.backAction))]
        
        collectionView?.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        loadMessages()

        // Do any additional setup after loading the view.
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        // Fix for IPhone X and above
        
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        
        // If the value is set between 1 - 999 the expected result is there, but if I set it to 1000 (as suggested
        // in the course, lesson 64 @4:21) it doesn't work.
        constraint.priority = UILayoutPriority(rawValue: 999)
        
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // end of IPhone X fix
        
        // Custom Send Button
        
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    }
    
    // MARK: - JSQMessages DataSource functions
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            cell.textView?.textColor = .white
        }
        else {
            cell.textView?.textColor = .black
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let data = messages[indexPath.row]
        
        if data.senderId == FUser.currentId() {
            return outgoingBubble
        }
        else {
            return incomingBubble
        }
    }
    
    // MARK: - JSQMessages Delegate functions
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { (action) in
            print("camera")
        }
        
        let sharePhoto = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            print("photo library")
        }
        
        let shareVideo = UIAlertAction(title: "Video Library", style: .default) { (action) in
            print("video library")
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (action) in
            print("share location")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }
        
        takePhotoOrVideo.setValue(UIImage(named: "camera"), forKey: "image")
        sharePhoto.setValue(UIImage(named: "picture"), forKey: "image")
        shareVideo.setValue(UIImage(named: "video"), forKey: "image")
        shareLocation.setValue(UIImage(named: "location"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(sharePhoto)
        optionMenu.addAction(shareVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        // for iPad not to crash I need to which device it is, i.e. the one line code "self.present(optionMenu..."
        // works fine for iPhones but not for iPads
        if ( UI_USER_INTERFACE_IDIOM() == .pad )
        {
            if let currentPopoverpresentioncontroller = optionMenu.popoverPresentationController{
                
                currentPopoverpresentioncontroller.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopoverpresentioncontroller.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                
                currentPopoverpresentioncontroller.permittedArrowDirections = .up
                self.present(optionMenu, animated: true, completion: nil)
            }
        }
        else{
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        if text != "" {
            self.sendMessage(text: text, date: date, picture: nil, location: nil, video: nil, audio: nil)
            
            updateSendButton(isSend: false)
        }
        else {
            print("audio message")
        }
    }
    
    // MARK: - Send Messages
    
    func sendMessage(text: String?, date: Date, picture: UIImage?, location: String?, video: NSURL?, audio: String?) {
        var outgoingMessage: OutgoingMessage?
        let currentUser = FUser.currentUser()!
        
        // text message
        
        if let text = text {
            outgoingMessage = OutgoingMessage(message: text, senderId: currentUser.objectId, senderName: currentUser.firstname, date: date, status: kDELIVERED, type: kTEXT)
        }
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outgoingMessage!.sendMsg(chatRoomId: chatRoomId, messageDict: outgoingMessage!.msgDictionary, memberIds: memberIds, membersToPush: membersToPush)
    }
    
    // MARK: - LoadMessages
    
    func loadMessages() {
        // get last 11 messages
        reference(.Message).document(FUser.currentId()).collection(chatRoomId).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapshot, error) in
            guard let snapshot = snapshot else {
                self.initalLoadComplete = true
                // listen for new chats
                return
            }
            
            let sorted = ((dictionaryFromSnapshots(snapshots: snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            // remove bad messages (corrupted etc)
            self.loadedMessages = self.removeBadMessages(allMessages: sorted)
            
            self.insertMessages()
            self.finishReceivingMessage(animated: true)
            
            self.initalLoadComplete = true
            
            print("we have \(self.messages.count) messages loaded")
            
            // get picture messages
            
            // get old messages in background
            
            // start listening for new chats
        }
    }
    
    // MARK: - InsertMessages
    
    func insertMessages() {
        maxMsgNumber = loadedMessages.count - loadedMsgsCount
        minMsgNumber = maxMsgNumber - kNUMBEROFMESSAGES
        
        if minMsgNumber < 0 {
            minMsgNumber = 0
        }
        
        for i in minMsgNumber ..< maxMsgNumber {
            let msgDict = loadedMessages[i]
            
            // insert message
            insertInitialLoadMessages(messageDictionary: msgDict)
            loadedMsgsCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (loadedMsgsCount != loadedMessages.count)
    }
    
    func insertInitialLoadMessages(messageDictionary: NSDictionary) -> Bool {
        // check if incoming
        let incomingMsg = IncomingMessage(collectionView_: self.collectionView!)
        
        if (messageDictionary[kSENDERID] as! String) != FUser.currentId() {
            // update message status
        }
        
        let msg = incomingMsg.createMessage(messageDictionary: messageDictionary, chatRoomId: chatRoomId)
        
        if msg != nil {
            objMessages.append(messageDictionary)
            messages.append(msg!)
        }
        
        return isIncoming(messageDictionary: messageDictionary)
    }
    
    // MARK: - IBActions
    
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - CustomSendButton
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        }
        else {
            updateSendButton(isSend: false)
        }
    }
    
    func updateSendButton(isSend: Bool) {
        if isSend {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "send"), for: .normal)
        }
        else {
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        }
    }
    
    // MARK: - Helper functions
    
    func removeBadMessages(allMessages: [NSDictionary]) -> [NSDictionary] {
        var tmpMessages = allMessages
        
        for msg in tmpMessages {
            if msg[kTYPE]  != nil {
                if !self.legitTypes.contains(msg[kTYPE] as! String) {
                    // remove the message
                    tmpMessages.remove(at: tmpMessages.firstIndex(of: msg)!)
                }
            }
            else {
                tmpMessages.remove(at: tmpMessages.firstIndex(of: msg)!)
            }
        }
        return tmpMessages
    }
    
    func isIncoming(messageDictionary: NSDictionary) -> Bool {
//        if FUser.currentId() == messageDictionary[kSENDERID] as! String {
//            return false
//        }
//        else {
//            return true
//        }
        
        return FUser.currentId() == messageDictionary[kSENDERID] as! String
    }
}
