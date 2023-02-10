//
//  FeedVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 28.01.2023.
//

import UIKit
import SDWebImage

class FeedVC: UICollectionViewController {
    
    //MARK: - Properties
    
    var user: User? {
        didSet {
            configureLeftBarItem()
        }
    }
    
    private var tweets = [Tweet]() {
        didSet {
            collectionView.reloadData()
        }
    }
    
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    //MARK: - API
    
    fileprivate func checkIfUserLikedTweets(_ tweets: [Tweet]) {
        for (index,tweet) in tweets.enumerated() {
            TweetService.shared.checkIfUserLikedTweet(tweet: tweet) { isLiked in
                guard isLiked == true else {return}
                self.tweets[index].isLiked = true
            }
        }
    }
    
    func fetchTweets() {
        TweetService.shared.fetchTweets { tweets in
            self.tweets = tweets
            self.checkIfUserLikedTweets(tweets)
            
        }
    }
    
    //MARK: - Functionality
    
    func configureUI() {
        
        fetchTweets()
        
        collectionView.register(TweetCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .white
        
        view.backgroundColor = .white
        
        let imageView = UIImageView(image: UIImage(named: "twitter_logo_blue"))
        imageView.contentMode = .scaleAspectFit
        imageView.setDimensions(width: 44, height: 44)
        navigationItem.titleView = imageView
    }
    
    func configureLeftBarItem() {
        guard let user = user else {return}
        
        let userImageView = UIImageView()
        userImageView.setDimensions(width: 36, height: 36)
        userImageView.layer.cornerRadius = 36 / 2
        userImageView.layer.masksToBounds = true
        userImageView.sd_setImage(with: user.userImageUrl)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: userImageView)
    }

}

//MARK: - CollectionView methods

extension FeedVC {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TweetCell
        cell.delegate = self
        cell.tweet = tweets[indexPath.row]
        
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = TweetVC(tweet: tweets[indexPath.row])
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

//MARK: - Parameters of CollectionView objects

extension FeedVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = TweetViewModel(tweet: tweets[indexPath.row])
        let height = viewModel.tweetSize(width: view.frame.width).height
        return CGSize(width: view.frame.width, height: height + 65)
    }
}

//MARK: - TweetCellDelegate

extension FeedVC: TweetCellDelegate {
    func likeTapped(cell: TweetCell) {
        guard let tweet = cell.tweet else {return}
        
        TweetService.shared.likeTweet(tweet: tweet) { error, reference in
            cell.tweet?.isLiked.toggle()
            let likes = tweet.isLiked ? tweet.likes - 1 : tweet.likes + 1
            cell.tweet?.likes = likes
            
            guard !tweet.isLiked else {return}
            NotificationService.shared.uploadNotification(type: .like, tweet: tweet)
        }
    }
    
    func replyTapped(cell: TweetCell) {
        guard let tweet = cell.tweet else {return}
        let controller = UploadTweetVC(user: tweet.user, config: .reply(tweet))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    func profileImageTapped(cell: TweetCell) {
        guard let user = cell.tweet?.user else {return}
        let vc = UserProfileVC(user: user)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
