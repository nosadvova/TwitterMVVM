//
//  TweetCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 02.02.2023.
//

import UIKit
import ActiveLabel

protocol TweetCellDelegate: AnyObject {
    func profileImageTapped(cell: TweetCell)
    func replyTapped(cell: TweetCell)
    func likeTapped(cell: TweetCell)
    
    func fetchUser(username: String)
}

class TweetCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var tweet: Tweet? {
        didSet {
            configure()
        }
    }
    
    weak var delegate: TweetCellDelegate?
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.setDimensions(width: 35, height: 35)
        image.layer.cornerRadius = 35 / 2
        image.backgroundColor = .blue
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tap)
        
        return image
    }()
    
    private let replyLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 12)
        
        return label
    }()
    
    private let captionLabel: ActiveLabel = {
        let label = ActiveLabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.mentionColor = .twitterBlue
        label.hashtagColor = .twitterBlue
        
        return label
    }()
    
    private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "Test Info"
        
        return label
    }()

    private lazy var likeButton: UIButton = {
        let button = createButton(imageName: "like", selectorName: #selector(likeTapped))
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = createButton(imageName: "retweet", selectorName: #selector(retweetTapped))
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = createButton(imageName: "comment", selectorName: #selector(commentTapped))
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        let button = createButton(imageName: "share", selectorName: #selector(shareTapped))
        return button
    }()
    
    private let underline: UIView = {
        let underlineView = UIView()
        underlineView.backgroundColor = .systemGroupedBackground
        
        return underlineView
    }()
    
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        addSubview(underline)
        underline.anchor(left: leftAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, right: rightAnchor, height: 1)
        
        let labelStack = UIStackView(arrangedSubviews: [userInfoLabel, captionLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 5
        
        let imageLabelStack = UIStackView(arrangedSubviews: [userImageView, labelStack])
        imageLabelStack.axis = .horizontal
        imageLabelStack.distribution = .fillProportionally
        imageLabelStack.spacing = 10
        imageLabelStack.alignment = .leading
        
        let stack = UIStackView(arrangedSubviews: [replyLabel, imageLabelStack])
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        stack.axis = .vertical
        stack.spacing = 8
        stack.distribution = .fillProportionally
        
        let buttonsStack = UIStackView(arrangedSubviews: [shareButton, commentButton, retweetButton, likeButton])
        addSubview(buttonsStack)
        buttonsStack.anchor(bottom: bottomAnchor, paddingBottom: 5)
        buttonsStack.spacing = 72
        buttonsStack.centerX(inView: self)
        buttonsStack.axis = .horizontal
        buttonsStack.tintColor = .darkGray
        
        handleMentionTapped()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func userImageTapped() {
        delegate?.profileImageTapped(cell: self)
    }
    
    @objc func shareTapped() {
        
    }
    
    @objc func commentTapped() {
        delegate?.replyTapped(cell: self)
    }
    
    @objc func retweetTapped() {
        
    }
    
    @objc func likeTapped() {
        delegate?.likeTapped(cell: self)
    }

    //MARK: - Functionality
    
    func configure() {
        guard let tweet = tweet else {return}
        
        let viewModel = TweetViewModel(tweet: tweet)
        
        replyLabel.isHidden = viewModel.shouldHideReplyLabel
        replyLabel.text = viewModel.replyText
        
        userImageView.sd_setImage(with: viewModel.userImageUrl)
        userInfoLabel.attributedText = viewModel.userInfoText
        captionLabel.text = tweet.caption
        
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
    }
    
    func createButton(imageName: String, selectorName: Selector) -> UIButton {
        let button = UIButton()
        button.setDimensions(width: 20, height: 20)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: selectorName, for: .touchUpInside)
        
        return button
    }
    
    func handleMentionTapped() {
        captionLabel.handleMentionTap { username in
            self.delegate?.fetchUser(username: username)
        }
    }
}
