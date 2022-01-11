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
    
    @IBOutlet weak var navigationItemConversations: UINavigationItem!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations = [Conversation]()
    
    private var result: [String: String] = [:]
    
    private var model: Conversation?
    
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
        conversationsView.register(UINib(nibName: K.conversationCellNibname, bundle: nil), forCellReuseIdentifier: K.conversationCellIdentifier)
        conversationsView.delegate = self
        conversationsView.dataSource = self
        fetchConversations()
        startListeningForConversations()
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
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        print(safeEmail)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: {[weak self] result in
            switch result {
            case .success(let conversations):
                guard !conversations.isEmpty else {
                    print("no convos")
                    return
                }
                print("got conversation")
                self?.conversations = conversations
                DispatchQueue.main.async {
                    print("reload data")
                    self?.conversationsView.reloadData()
                }
            case .failure(let error):
                print("failed to get convos: \(error)")
            }
        })
    }
    
    // This function is called before the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get a reference to the second view controller
        print(segue.identifier)
        if (segue.identifier == K.newChatSegue) {
            let newConversationsViewController = segue.destination as! NewConversationViewController
            // Set a variable in the second view controller with the String to pass
            newConversationsViewController.completion = { [weak self] result in
                self?.result = result
                print("RESULT")
                print(result)
                self?.createNewConversation()
            }
        } else if (segue.identifier! == K.chatSegue) {
            let chatViewController = segue.destination as! ChatViewController
            if model != nil {
                chatViewController.conversationId = model?.id ?? ""
                chatViewController.title = model?.name
                chatViewController.otherUserEmail = model?.otherUserEmail ?? ""
            } else {
                chatViewController.title = result["username"]
                chatViewController.otherUserEmail = result["email"] ?? ""
                chatViewController.isNewConversation = true
            }
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
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        print("Id: \(model.id)")
        print("latest message text: \(model.latestMessage.text)")
        print(conversations.count)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.conversationCellIdentifier, for: indexPath) as! ConversationTableViewCell
        cell.userTextLabel.text = model.latestMessage.text
        cell.usernameLabel.text = model.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        model = conversations[indexPath.row]
        self.performSegue(withIdentifier: K.chatSegue, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
