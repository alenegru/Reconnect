//
//  RegisterViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 25/10/2021.
//

import UIKit
import Firebase
import JGProgressHUD

class RegisterViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var reEnterPasswordField: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton?) {
        guard let username = usernameField.text,
            let email = emailField.text,
            let password = passwordField.text,
            let rePassword = reEnterPasswordField.text,
            !email.isEmpty,
            !password.isEmpty,
            !username.isEmpty,
            password == rePassword,
            password.count >= 6 else {
            alertUserRegisterError()
                return
        }
        
        spinner.show(in: view)
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                self.alertUserRegisterError(message: "User with this email already exists.")
                self.spinner.dismiss()
                return
            }
            
            DispatchQueue.main.async {
                self.spinner.dismiss()
            }

            UserDefaults.standard.setValue(email, forKey: "email")
            UserDefaults.standard.setValue(username, forKey: "username")
            
            let chatUser = User(username: username,
                                email: email)
            DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                if success {
                    print("success")
                }
            })
            
            self.performSegue(withIdentifier: K.registerSegue, sender: self)
        })

    }
    
    func alertUserRegisterError(message: String = "Please enter all information to create a new account.") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:"Dismiss",
                                      style: .cancel, handler: nil))
        present(alert, animated: true)
    }
    

}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == emailField {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            registerButtonPressed(nil)
        }

        return true
    }

}

