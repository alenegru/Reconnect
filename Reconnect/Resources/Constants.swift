//
//  Constants.swift
//  Reconnect
//
//  Created by Alexandra Negru on 31/10/2021.
//

import Foundation

import Foundation

struct K {
    static let appName = "Reconnect"
    static let registerSegue = "registerToChat"
    static let loginSegue = "loginToChat"
    static let chatSegue = "chatSegue"
    static let searchSegue = "searchSegue"
    static let newChatSegue = "newChatSegue"
     
    struct FStore {
        static let collectionName = "messages"
        static let senderField = "sender"
        static let bodyField = "body"
        static let dateField = "date"
    }
}
