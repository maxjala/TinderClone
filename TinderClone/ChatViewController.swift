//
//  ChatViewController.swift
//  TinderClone
//
//  Created by Max Jala on 29/05/2017.
//  Copyright © 2017 Max Jala. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import Firebase

class ChatViewController: JSQMessagesViewController {
    
    @IBOutlet weak var goBackButton: UIButton! {
        didSet {
            goBackButton.addTarget(self, action: #selector(goBackButtonTapped), for: .touchUpInside)
            goBackButton.layer.cornerRadius = goBackButton.frame.height/2
            goBackButton.layer.masksToBounds = true
        }
    }

    var ref: DatabaseReference!
    var newChats: [Any] = []
    var messages = [JSQMessage]()
    let currentUserID = UserDefaults.getUserID()
    let currenUserName = UserDefaults.getUserName()
    var matchedUser : User?
    var matchedIDs : [String] = []
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //fetchAndCreateChatHistory()
        //view.addSubview(goBackButton)
        //view.bringSubview(toFront: goBackButton)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        self.senderId = currentUserID
        self.senderDisplayName = currenUserName
        
        fetchAndCreateChatHistory()

    }
    
    func fetchAndCreateChatHistory() {
        messages = []
        
        matchedIDs = [currentUserID!, (matchedUser?.id)!]
        
        //matchedIDs.sorted()
        
        let matchID = "\(matchedIDs.sorted()[0])-\(matchedIDs.sorted()[1])"
        
        ref.child("matches").child(matchID).child("messages").observe(.childAdded, with: { (snapshot) in
            guard let messageDict = snapshot.value as? [String:Any] else {return}
            
            self.addToMessages(snapshot.key, messageDict: messageDict)
            
            self.collectionView.reloadData()
            
        })
    }
    
    func addToMessages(_ id: Any, messageDict: [String:Any]) {
        
        if let senderID = messageDict["senderID"] as? String ,
            let displayName = messageDict["senderName"] as? String,
            let date = messageDict["timeStamp"] as? String,
            let text = messageDict["body"] as? String {
            
            let timestamp = Double(date)
            let formattedDate = Date(timeIntervalSince1970: timestamp!)
            
            let message = JSQMessage(senderId: senderID, senderDisplayName: displayName, date: formattedDate, text: text)
            self.messages.append(message!)
            
        }
    }
    
    func sendText(_ messageDict: [String: Any]) {
        let matchID = "\(matchedIDs.sorted()[0]))-\(matchedIDs.sorted()[1])"
        let timeStamp = "\(Date().timeIntervalSince1970)"
        
        ref.child("matches").child(matchID).child("messages").child(timeStamp).updateChildValues(messageDict)
    }
    
    func goBackButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
}


extension ChatViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let matchID = "\(matchedIDs.sorted()[0])-\(matchedIDs.sorted()[1])"
        let time = Date().timeIntervalSince1970
        let timeStamp = Int(time)
        //let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        let sentDict = ["senderID" : senderId,"senderName": senderDisplayName, "timeStamp" : "\(timeStamp)", "body" : text]
        
        ref.child("matches").child(matchID).child("messages").child("\(timeStamp)").updateChildValues(sentDict)
        
        if messages.count != 0 {
            collectionView.scrollToItem(at: [messages.count - 1], at: .bottom, animated: true)
        }

        finishSendingMessage()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        let messageUserName = message.senderDisplayName
        
        return NSAttributedString(string: messageUserName!)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        let message = messages[indexPath.row]
        
        guard let id = currentUserID else {return nil}
        
        if id == message.senderId {
            return bubbleFactory?.outgoingMessagesBubbleImage(with: UIColor(red: 240/255.0, green: 133/255.0, blue: 91/255.0, alpha: 0.8))
        } else {
            return bubbleFactory?.incomingMessagesBubbleImage(with: .gray)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
}

