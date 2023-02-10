//
//  TweetCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 02.02.2023.
//

import UIKit

protocol TweetCellDelegate: AnyObject {
    func profileImageTapped(cell: TweetCell)
    func replyTapped(cell: TweetCell)
    func likeTapped(cell: TweetCell)
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
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        
        return label
    }()
    
    private let userInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.text = "Test Info"
        
        return label
    }()
    
    
    private lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "share"), for: .normal)
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "comment"), for: .normal)
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(commentTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var retweetButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "retweet"), for: .normal)
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(retweetTapped), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "like"), for: .normal)
        button.setDimensions(width: 20, height: 20)
        button.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        
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
        
        addSubview(userImageView)
        userImageView.anchor(top: safeAreaLayoutGuide.topAnchor, left: leftAnchor, paddingTop: 10, paddingLeft: 7)
        
        let labelStack = UIStackView(arrangedSubviews: [userInfoLabel, captionLabel])
        addSubview(labelStack)
        labelStack.anchor(top: topAnchor, left: userImageView.rightAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10)
        labelStack.axis = .vertical
        labelStack.spacing = 5
        
        let buttonsStack = UIStackView(arrangedSubviews: [shareButton, commentButton, retweetButton, likeButton])
        addSubview(buttonsStack)
        buttonsStack.anchor(bottom: bottomAnchor, paddingBottom: 5)
        buttonsStack.spacing = 72
        buttonsStack.centerX(inView: self)
        buttonsStack.axis = .horizontal
        buttonsStack.tintColor = .darkGray
        
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
        
        userImageView.sd_setImage(with: viewModel.userImageUrl)
        userInfoLabel.attributedText = viewModel.userInfoText
        captionLabel.text = tweet.caption
        likeButton.tintColor = viewModel.likeButtonTintColor
        likeButton.setImage(viewModel.likeButtonImage, for: .normal)
    }
}
