//
//  TweetHeader.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 06.02.2023.
//

import UIKit

protocol TweetHeaderDelegate: AnyObject {
    func actionSheet()
}

class TweetHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    var tweet: Tweet? {
        didSet {configureTweet()}
    }
    
    weak var delegate: TweetHeaderDelegate?
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 4
        image.setDimensions(width: 55, height: 55)
        image.layer.cornerRadius = 55 / 2
        image.backgroundColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tap)
        
        return image
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "Name Surname"
        
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.text = "username"
        
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.text = "Tweet text long long long textttttt"
        
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.textAlignment = .left
        label.text = "19.04.2003"
        
        return label
    }()
    
    private lazy var likesLabel: UILabel = {
        let label = UILabel()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(likesLabelTapped))
        label.addGestureRecognizer(recognizer)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var retweetsLabel: UILabel = {
        let label = UILabel()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(retweetsLabelTapped))
        label.addGestureRecognizer(recognizer)
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    private lazy var statsView: UIView = {
        let view = UIView()
        let divider1 = UIView()
        let divider2 = UIView()
        
        divider1.backgroundColor = .systemGroupedBackground
        view.addSubview(divider1)
        divider1.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1)
                
        divider2.backgroundColor = .systemGroupedBackground
        view.addSubview(divider2)
        divider2.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 8, height: 1)
        
        let stack = UIStackView(arrangedSubviews: [retweetsLabel, likesLabel])
        view.addSubview(stack)
        stack.axis = .horizontal
        stack.spacing = 10
        stack.centerY(inView: view)
        stack.anchor(left: view.leftAnchor, paddingLeft: 15)
        
        
        return view
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "down_arrow_24pt"), for: .normal)
        button.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        
        return button
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
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        configureTweet()  
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func userImageTapped() {
        
    }
    
    @objc func optionButtonTapped() {
        delegate?.actionSheet()
    }
    
    @objc func likesLabelTapped() {
        
    }
    
    @objc func retweetsLabelTapped() {
        
    }
    
    @objc func likeTapped() {
        print("like tapped")
    }
    
    @objc func retweetTapped() {
        print("retweet tapped")
    }
    
    @objc func commentTapped() {
        
    }
    
    @objc func shareTapped() {
        
    }
    
    //MARK: - Functionality
    
    private func configureUI() {
        
        let labelsStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 1
        
        let stack = UIStackView(arrangedSubviews: [userImageView, labelsStack])
        stack.axis = .horizontal
        stack.spacing = 10
        
        addSubview(stack)
        stack.anchor(top: topAnchor, left: leftAnchor, paddingTop: 7, paddingLeft: 10)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20, paddingLeft: 15, paddingRight: 15)
        
        addSubview(timeLabel)
        timeLabel.anchor(top: captionLabel.bottomAnchor, left: leftAnchor, paddingTop: 20, paddingLeft: 16)
        
        addSubview(optionsButton)
        optionsButton.centerY(inView: stack)
        optionsButton.anchor(right: rightAnchor, paddingRight: 8)
        
        addSubview(statsView)
        statsView.anchor(top: timeLabel.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 20, height: 35)
        
        let buttonStack = UIStackView(arrangedSubviews: [shareButton, commentButton, retweetButton, likeButton])
        addSubview(buttonStack)
        buttonStack.spacing = 72
        buttonStack.distribution = .fillEqually
        buttonStack.centerX(inView: self)
        buttonStack.tintColor = .darkGray
        buttonStack.anchor(top: statsView.bottomAnchor, paddingTop: 15)
    }
    
    func configureTweet() {
        guard let tweet = tweet else {return}
        let viewModel = TweetViewModel(tweet: tweet)
        
        userImageView.sd_setImage(with: viewModel.userImageUrl)
        fullnameLabel.text = viewModel.user.fullname
        usernameLabel.text = viewModel.usernameText
        
        captionLabel.text = tweet.caption
        timeLabel.text = viewModel.timestamp
        
        likesLabel.attributedText = viewModel.likesAttributedString
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
        likeButton.tintColor = viewModel.likeButtonTintColor
        
        retweetsLabel.attributedText = viewModel.retweetsAttributedString
        
    }
    
    func createButton(imageName: String, selectorName: Selector) -> UIButton {
        let button = UIButton()
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(self, action: selectorName, for: .touchUpInside)
        
        return button
    }
        
}
