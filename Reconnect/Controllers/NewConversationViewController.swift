//
//  NewConversationViewController.swift
//  Reconnect
//
//  Created by Alexandra Negru on 08/11/2021.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    
    private let spinner =  JGProgressHUD()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "usersCell")
        return table
    }()

    private let noResultsLabel: UILabel = {
        let label = UILabel()
        label.isHidden = false
        label.text = "No Results"
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noResultsLabel)
        view.addSubview(tableView)
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noResultsLabel.frame = CGRect(x: view.bounds.width/4,
                                      y: (view.bounds.height-200)/2,
                                      width: view.bounds.width/2,
                                      height: 200)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath)
        cell.textLabel?.text = "User"
        return cell
    }
    
    
}
