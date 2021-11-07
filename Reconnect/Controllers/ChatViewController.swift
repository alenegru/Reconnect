//
//  ChatViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 07/11/2021.
//

import UIKit
import MessageKit

class ChatViewController: MessagesViewController {
    private var messages = [Message]()
    
    private let sender = Sender(senderId: "1", displayName: "Laura Goron")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: sender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello")))
        messages.append(Message(sender: sender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello")))
        messages.append(Message(sender: sender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return sender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
