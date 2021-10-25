//
//  LoginViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 25/10/2021.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    let username: String = "ale"
    let password: String = "parola"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        let username = usernameField.text
        let password = passwordField.text
        
        if (username == self.username && password == self.password) {
            performSegue(withIdentifier: "conversationsIdentifier", sender: self)
        } else {
            print("Incorrect user")
        }
    }
    
}
