///
//  DatabaseManager.swift
//  Reconnect
//
//  Created by Alexandra Negru on 07/11/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database(url: "https://reconnect-1bc2b-default-rtdb.europe-west1.firebasedatabase.app").reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

//MARK: - Account Management

extension DatabaseManager {
    
    ///Inserts new user to database
    public func insertUser(with user: User, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
                "username": user.username
            ], withCompletionBlock: { [weak self] error, _ in

                guard let strongSelf = self else {
                    return
                }

                guard error == nil else {
                    print("failed to write to database")
                    completion(false)
                    return
                }

                strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // append to user dictionary
                        let newElement = [
                            "username": user.username,
                            "email": user.email
                        ]
                        usersCollection.append(newElement)

                        strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            completion(true)
                        })
                    }
                    else {
                        // create that array
                        let newCollection: [[String: String]] = [
                            [
                                "username": user.username,
                                "email": user.email
                            ]
                        ]

                        strongSelf.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }

                            completion(true)
                        })
                    }
                })
            })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
            database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [[String: String]] else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }

                completion(.success(value))
            })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch

        public var localizedDescription: String {
            switch self {
            case .failedToFetch:
                return "This means blah failed"
            }
        }
    }
}

extension DatabaseManager {

    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }

}

//MARK: - Sending messages

extension DatabaseManager {
    public func createNewConversation(with otherUserEmail: String, otherUserName: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
            guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                  let currentName = UserDefaults.standard.value(forKey: "username") as? String else {
                    print("no user")
                    return
            }
            let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)

            let ref = database.child("\(safeEmail)")

            ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                guard var userNode = snapshot.value as? [String: Any] else {
                    completion(false)
                    print("user not found")
                    return
                }

                let messageDate = firstMessage.sentDate
                let dateString = ChatViewController.dateFormatter.string(from: messageDate)

                var message = ""

                switch firstMessage.kind {
                case .text(let messageText):
                    message = messageText
                case .attributedText(_):
                    break
                case .photo(_):
                    break
                case .video(_):
                    break
                case .location(_):
                    break
                case .emoji(_):
                    break
                case .audio(_):
                    break
                case .contact(_):
                    break
                case .custom(_):
                    break
                }

                let conversationId = "conversation_\(firstMessage.messageId)"

                let newConversationData: [String: Any] = [
                    "id": "conversation_\(firstMessage.messageId)",
                    "other_user_email": otherUserEmail,
                    "other_user_name": otherUserName,
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                    ]
                ]

                let recipient_newConversationData: [String: Any] = [
                    "id": conversationId,
                    "other_user_email": safeEmail,
                    "other_user_name": currentName,
                    "latest_message": [
                        "date": dateString,
                        "message": message,
                        "is_read": false
                    ]
                ]
                
                //Update recipient conversation entry
                let safeOtherUserEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
                // Update recipient conversaiton entry
                self?.database.child("\(safeOtherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                    if var conversations = snapshot.value as? [[String: Any]] {
                        // append
                        conversations.append(recipient_newConversationData)
                        self?.database.child("\(safeOtherUserEmail)/conversations").setValue(conversations)
                    }
                    else {
                        // create
                        self?.database.child("\(safeOtherUserEmail)/conversations").setValue([recipient_newConversationData])
                    }
                })

                // Update current user conversation entry
                if var conversations = userNode["conversations"] as? [[String: Any]] {
                    // conversation array exists for current user
                    // you should append
                    conversations.append(newConversationData)
                    userNode["conversations"] = conversations
                    ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        self?.finishCreatingConversation(otherUserName: otherUserName,
                                                         conversationID: "conversation_\(firstMessage.messageId)",
                                                         firstMessage: firstMessage,
                                                         completion: completion)
                    })
                } else {
                    // conversation array does NOT exist
                    // create it
                    userNode["conversations"] = [
                        newConversationData
                    ]

                    ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }

                        self?.finishCreatingConversation(otherUserName: otherUserName,
                                                         conversationID: "conversation_\(firstMessage.messageId)",
                                                         firstMessage: firstMessage,
                                                         completion: completion)
                    })
                }
            })
        }
    
    private func finishCreatingConversation(otherUserName: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
    //        {
    //            "id": String,
    //            "type": text, photo, video,
    //            "content": String,
    //            "date": Date(),
    //            "sender_email": String,
    //            "isRead": true/false,
    //        }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)

            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .custom(_):
                break
            }

            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }

            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)

            let collectionMessage: [String: Any] = [
                "id": firstMessage.messageId,
                "type": firstMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": otherUserName
            ]

            let value: [String: Any] = [
                "messages": [
                    collectionMessage
                ]
            ]

            print("adding convo: \(conversationID)")

            database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        }
    
    public func getAllConversations(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let conversations: [Conversation] = value.compactMap ({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                      let name = dictionary["other_user_name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String:Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            })
            
            completion(.success(conversations))
        }
    }
    
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let messages: [Message] = value.compactMap ({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageId = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                let sender = Sender(senderId: senderEmail,
                                    displayName: name)
                return Message(sender: sender,
                               messageId: messageId,
                               sentDate: date,
                               kind: .text(content))
            })
            
            completion(.success(messages))
        }
    }
    
    public func sendMessage(to conversation: String, otherUserEmail: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)

            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_), .photo(_), .video(_), .location(_), .emoji(_), .audio(_), .contact(_), .custom(_):
                break
            }

            guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                completion(false)
                return
            }

            let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)

            let newMessage: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessage)
            
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    var targetConversation: [String: Any]?
                    
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConversation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConversation
                    strongSelf.database.child("\(currentUserEmail)/conversations").setValue(currentUserConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        //Update latest message for receiving recipient user
                        let safeOtherUserEmail = DatabaseManager.safeEmail(emailAddress: otherUserEmail)
                        strongSelf.database.child("\(safeOtherUserEmail)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            
                            var targetConversation: [String: Any]?
                            
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations {
                                if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConversation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConversation
                            strongSelf.database.child("\(safeOtherUserEmail)/conversations").setValue(otherUserConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
}

//MARK: - Calendar events

extension DatabaseManager{
    public func insertEvents(events:[UserEvent], completion: @escaping (Bool) -> Void){
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String,
                        let currentUsername = UserDefaults.standard.value(forKey: "username") as? String else {
                            return
                    }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        let ref = database.child(safeEmail)
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
                        guard var userNode = snapshot.value as? [String: Any] else {
                            completion(false)
                            print("user not found")
                            return
                        }
            //delete everithing from events if existing
            userNode.removeValue(forKey: "events")
//            ref.child("events").observeSingleEvent(of: .value, with: { [weak self] snapshot in
//                guard var eventNode = snapshot.value as? [String: Any]
//                else {
//                    completion(false)
//                    print("events not found for this user")
//                    return
//                }
          
            for event in events {
                
                let newEventData: [String: Any] = [
                    "startDate": event.startDate,
                    "endDate": event.endDate,
                    "text": event.text,
                    "color": event.color,
                    "isAllDay": event.isAllDay
                ]
                
                if var userEvents = userNode["events"] as? [[String: Any]] {
                                    // conversation array exists for current user
                                    // you should append
                    userEvents.append(newEventData)
                                    userNode["events"] = userEvents
                                    ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                                        guard error == nil else {
                                            completion(false)
                                            return
                                        }
                                    })
                                }
                                else {
                                    // conversation array does NOT exist
                                    // create it
                                    userNode["events"] = [
                                        newEventData
                                    ]
                }

            }
        })
    }
    
    public func getAllEvents(for email: String, completion: @escaping (Result<[UserEvent], Error>) -> Void) {
        //database.child("a-b-com/events").observe(.value)
        database.child("\(email)/events").observe(.value) {
            (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            let events: [UserEvent] = value.compactMap ({ dictionary in
                guard let startDate_ = dictionary["startDate"] as? String,
                      let endDate_ = dictionary["endDate"] as? String,
                      let text_ = dictionary["text"] as? String,
                      let color_ = dictionary["color"] as? String,
                      let isAllDay_ = dictionary["isAllDay"] as? Bool
                else {
                    return nil
                }
                
                return UserEvent(startDate:startDate_,
                                 endDate: endDate_,
                                 isAllDay: isAllDay_,
                                 text: text_,
                                 color: color_)
            })
            
            completion(.success(events))
        }
    }
}

struct User {
    let username: String
    let email: String
    var safeEmail: String {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    let status: String
}



