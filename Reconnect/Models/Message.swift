//
//  Message.swift
//  Reconnect
//
//  Created by Alexandra Negru on 30/10/2021.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}
