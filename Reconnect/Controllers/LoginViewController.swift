//
//  LoginViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 25/10/2021.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        guard let email = emailField.text,
              let password = passwordField.text,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
                alertUserLoginError()
                return
        }

        // Firebase Log In
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {authResult, error in
                guard let result = authResult, error == nil else {
                    print("Failed to log in user with email: \(email)")
                    return
                }

                let user = result.user
                UserDefaults.standard.setValue(email, forKey: "email")
            
                self.performSegue(withIdentifier: K.registerSegue, sender: self)
        })
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
}
