//
//  ChatViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 07/11/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    private var messages = [Message]()
    public var isNewConversation = false
    public var otherUserEmail: String = ""
    public var conversationId: String = ""
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var sender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(senderId: safeEmail,
               displayName: "Me")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        listenForMessages(shouldScrollToBottom: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == K.calendarSegue) {
            // Get a reference to the second view controller
            let userCalendarViewController = segue.destination as! DailyViewController

            // Set a variable in the second view controller with the String to pass
            print("OTHER USER EMAIL")
            print(otherUserEmail)
            userCalendarViewController.currentUser = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
        }
    }
    
    
    
    private func listenForMessages(shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: conversationId, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
            case .failure(let error):
                print("failed to get messages: \(error)")
            }
        })
    }

}

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let sender = self.sender,
              let messageId = createMessageId() else {
            return
        }
        
        let message = Message(sender: sender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        
        if isNewConversation {
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, otherUserName: self.title ?? "User", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("message sent")
                    self?.isNewConversation = false
                } else {
                    print("failed to send")
                }
            })
        } else {
            
            guard let name = self.title else {
                return
            }
            DatabaseManager.shared.sendMessage(to: self.conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    self.messageInputBar.inputTextView.text = nil
                    print("message sent")
                } else {
                    print("failed to send")
                }
                
            })
        }
    }
    
    private func createMessageId() -> String? {
            // date, otherUesrEmail, senderEmail, randomInt
            guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return nil
            }

            let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)

            let safeOtherUserEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
            let dateString = Self.dateFormatter.string(from: Date())
            let newIdentifier = "\(safeOtherUserEmail)_\(safeCurrentEmail)_\(dateString)"

            print("created message id: \(newIdentifier)")

            return newIdentifier
        }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = self.sender {
            return sender
        }
        fatalError("Sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
