//
//  MainTabBarVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 28.01.2023.
//

import UIKit
import FirebaseAuth

class MainTabBarVC: UITabBarController {
    
    var user: User? {
        didSet {
            guard let nav = viewControllers?[0] as? UINavigationController else {return}
            guard let feedVC = nav.viewControllers[0] as? FeedVC else {return}
            
            feedVC.user = user
        }
    }
        
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = .twitterBlue
        button.setImage(UIImage(named: "new_tweet"), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - App Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .twitterBlue
        
//        logOut()
        authenticateUserAndConfigureUI()
    }
    
    //MARK: - API
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func authenticateUserAndConfigureUI() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginVC())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            }
        } else {
            configureViewControllers()
            configureUI()
            fetchUser()
        }
    }
    
    func logOut() {
        do {
           try Auth.auth().signOut()
        } catch {
            print("logOut() error")
        }
    }
    
    //MARK: - Selectors
    
    @objc func actionButtonPressed() {
        guard let user = user else {return}
        let uploadTweetVC = UploadTweetVC(user: user, config: .tweet)
        let nav = UINavigationController(rootViewController: uploadTweetVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    //MARK: - Functionality
    
    func configureUI() {
        view.addSubview(actionButton)
        
        actionButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingBottom: 80, paddingRight: 25, width: 45, height: 45)
        actionButton.layer.cornerRadius = 45 / 2
        
        tabBar.backgroundColor = .systemGray6
    }
    
    func configureViewControllers() {
        let feedNav = templateNavigationController(UIImage(named: "home_unselected"), FeedVC(collectionViewLayout: UICollectionViewFlowLayout()))

        let exploreNav = templateNavigationController(UIImage(named: "search_unselected"), ExploreVC())
        
        let notificationNav = templateNavigationController(UIImage(named: "like_unselected"),NotificationsVC())
        
        let chatNav = templateNavigationController(UIImage(named: "mail_unselected"), ChatsVC())

        viewControllers = [feedNav, exploreNav, notificationNav, chatNav]
    }
    
    func templateNavigationController(_ image: UIImage?, _ rootViewController: UIViewController) -> UINavigationController {
        let navVC = UINavigationController(rootViewController: rootViewController)
        navVC.tabBarItem.image = image
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        navVC.navigationBar.standardAppearance = appearance
        navVC.navigationBar.scrollEdgeAppearance = navVC.navigationBar.standardAppearance
        
        return navVC
    }
}
