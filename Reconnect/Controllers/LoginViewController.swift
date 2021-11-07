//
//  LoginViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 25/10/2021.
//

import UIKit
import Firebase
import JGProgressHUD

class LoginViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    
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
        
        spinner.show(in: view)

        // Firebase Log In
        Auth.auth().signIn(withEmail: email, password: password, completion: {authResult, error in
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
                
            guard let result = authResult, error == nil else {
                    print("Failed to log in user with email: \(email)")
                    return
            }

            let user = result.user
                UserDefaults.standard.setValue(email, forKey: "email")
            
            self.performSegue(withIdentifier: K.loginSegue, sender: self)
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
