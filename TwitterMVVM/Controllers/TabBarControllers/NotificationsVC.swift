//
//  NotificationsVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 28.01.2023.
//

import UIKit
import FirebaseAuth

private let cellIdentifier = "cell"

class NotificationsVC: UITableViewController {
    
    //MARK: - Properties
    
    private var notifications = [Notification]() {
        didSet {tableView.reloadData()}
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    //MARK: - API
    
    fileprivate func checkIfUserIsFollowed(_ notifications: [Notification]) {
        guard !notifications.isEmpty else {return}
        
        notifications.forEach { notification in
            guard case .follow = notification.type else {return}
            let user = notification.user
            
            UserService.shared.checkIfUserIsFollowed(uid: user.uid) { isFollowed in
                if let index = self.notifications.firstIndex(where: { $0.user.uid == notification.user.uid}) {
                    self.notifications[index].user.isFollowed = isFollowed
                }
            }
        }
    }
    
    func fetchNotifications() {
        refreshControl?.beginRefreshing()
        NotificationService.shared.fetchNotifications { notifications in
            self.notifications = notifications
            self.checkIfUserIsFollowed(notifications)
            self.refreshControl?.endRefreshing()
        }
    }
    
    //MARK: - Selectors
    
    @objc func refreshPage() {
        fetchNotifications()
    }
    
    //MARK: - Functionality
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Notifications"
        
        tableView.register(NotificationCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        
        let refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPage), for: .valueChanged)
    }
}
    
    
    //MARK: - TableViewDataSource
    
    extension NotificationsVC {
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return notifications.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! NotificationCell
            
            cell.notification = notifications[indexPath.row]
            cell.delegate = self
            return cell
        }
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            let notification = notifications[indexPath.row]
            guard let tweetId = notification.tweetId else {return}
            
            TweetService.shared.fetchTweet(tweetId: tweetId) { tweet in
                let vc = TweetVC(tweet: tweet)
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    //MARK: - NotificationCellDelegate
    
    extension NotificationsVC: NotificationCellDelegate {
        func followTapped(cell: NotificationCell) {
            guard let user = cell.notification?.user else {return}
            
            if user.isFollowed {
                UserService.shared.unfollowUser(uid: user.uid) { error, reference in
                    cell.notification?.user.isFollowed = false
                }
            } else {
                UserService.shared.followUser(uid: user.uid) { error, reference in
                    cell.notification?.user.isFollowed = true
                }
            }
        }
        
        func profileImageTapped(cell: NotificationCell) {
            guard let user = cell.notification?.user else {return}
            let vc = UserProfileVC(user: user)
            navigationController?.pushViewController(vc, animated: true)
        }
    }
