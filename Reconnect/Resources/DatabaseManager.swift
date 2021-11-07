//
//  DatabaseManager.swift
//  Reconnect
//
//  Created by Alexandra Negru on 07/11/2021.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

//MARK: - Account Management

extension DatabaseManager {
    
    ///Inserts new user to database
    public func insertUser(with user: User) {
        database.child(user.email).setValue([
            "username": user.username
        ])
    }
}

struct User {
    let username: String
    let email: String
}
