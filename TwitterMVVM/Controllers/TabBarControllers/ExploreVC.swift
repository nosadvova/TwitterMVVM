//
//  ExploreVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 28.01.2023.
//

import UIKit

private let cellIdentifier = "cell"

class ExploreVC: UITableViewController {
    
    //MARK: - Properties
    
    private var users = [User]() {
        didSet { tableView.reloadData() }
    }
    
    private var filterUsers = [User]() {
        didSet {tableView.reloadData()}
    }
    
    private var insSearchMode: Bool {
        return searchController.isActive && !searchController.searchBar.text!.isEmpty
    }
    private let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchUsers()
        configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - API
    
    func fetchUsers() {
        UserService.shared.fetchUser { users in
            self.users = users
        }
    }
    
    //MARK: - Functionality
    
    func configureUI() {
        tableView.register(FollowUserCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.rowHeight = 65
        
        view.backgroundColor = .white
        navigationItem.title = "Explore"
    }
    
    func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for a user"
        navigationItem.searchController = searchController
        definesPresentationContext = false
    }
}

//MARK: - UITableView

extension ExploreVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return insSearchMode ? filterUsers.count : users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! FollowUserCell
        let user = insSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        
        cell.user = user
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = insSearchMode ? filterUsers[indexPath.row] : users[indexPath.row]
        let controller = UserProfileVC(user: user)
        navigationController?.pushViewController(controller, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchResultsUpdating

extension ExploreVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased() else {return}
        
        filterUsers = users.filter({$0.username.contains(searchText)})
    }
    
    
    
}
