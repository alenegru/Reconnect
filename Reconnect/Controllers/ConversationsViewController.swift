//
//  ConversationsViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 25/10/2021.
//

import UIKit
import Firebase
import JGProgressHUD

class ConversationsViewController: UIViewController {
    @IBOutlet weak var conversationsView: UITableView!
    
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var result: [String: String] = [:]
    
    let db = Firestore.firestore()
    
    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "No conversations yet"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noConversationsLabel)
        
        validateAuth()
        //conversationsView.isHidden = true
        conversationsView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        conversationsView.delegate = self
        conversationsView.dataSource = self
        fetchConversations()
        //DatabaseManager.shared.test()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.bounds.height-100)/2,
                                            width: view.bounds.width-20,
                                            height: 100)
    }
    
    private func validateAuth() {
        if Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func fetchConversations() {
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Get a reference to the second view controller
        if (segue.identifier == K.newChatSegue) {
            let newConversationsViewController = segue.destination as! NewConversationViewController

            // Set a variable in the second view controller with the String to pass
            newConversationsViewController.completion = { [weak self] result in
                self?.result = result
                self?.createNewConversation()
            }
        } else if (segue.identifier == K.chatSegue) {
            let chatViewController = segue.destination as! ChatViewController
            guard let username = result["username"], let email = result["email"] else {
                return
            }
            chatViewController.title = username
            chatViewController.otherUserEmail = email
            chatViewController.isNewConversation = true
        }
    }

    
    @IBAction func composeButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: K.newChatSegue, sender: self)
    }
    
    private func createNewConversation() {
        self.performSegue(withIdentifier: K.chatSegue, sender: self)
    }
    
    
}
    // MARK: - Table view data source
extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Convo"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.performSegue(withIdentifier: K.chatSegue, sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

}
