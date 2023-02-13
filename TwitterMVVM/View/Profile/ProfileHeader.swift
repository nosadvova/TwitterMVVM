//
//  ProfileHeader.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 03.02.2023.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func dismissScreen()
    func editProfileFollowUserTapped(header: ProfileHeader)
    func didSelectCategory(category: ProfileCategoryOptions)
}

class ProfileHeader: UICollectionReusableView {
    
    //MARK: - Properties
    
    private let profileCategory = ProfileCategory()
    
    weak var delegate: ProfileHeaderDelegate?
    
    var user: User? {
        didSet {configure()}
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        view.addSubview(backButton)
        
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 15)
        backButton.setDimensions(width: 30, height: 30)
        
       
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "baseline_arrow_back_white_24dp"), for: .normal)
        button.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
       
        return button
    }()
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 4
        image.setDimensions(width: 80, height: 80)
        image.layer.cornerRadius = 80 / 2
        image.backgroundColor = .gray
        
        return image
    }()
    
     lazy var editProfileButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.twitterBlue, for: .normal)
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1.5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(editProfileTapped), for: .touchUpInside)
        
        button.setDimensions(width: 100, height: 30)
        button.layer.cornerRadius = 30 / 2
        
        return button
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    private let bioLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 3
        
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(followingLabelTapped))
        label.addGestureRecognizer(recognizer)
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(followersLabelTapped))
        label.addGestureRecognizer(recognizer)
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
    
    //MARK: - Selectors
    
    @objc func backTapped() {
        delegate?.dismissScreen()
    }
    
    @objc func editProfileTapped() {
        delegate?.editProfileFollowUserTapped(header: self)
    }
    
    @objc func followingLabelTapped() {
        
    }
    
    @objc func followersLabelTapped() {
        
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        profileCategory.delegate = self
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 100)
        
        addSubview(userImageView)
        userImageView.anchor(top: containerView.bottomAnchor, left: leftAnchor, paddingTop: -24, paddingLeft: 8)
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: containerView.bottomAnchor, right: rightAnchor, paddingTop: 20, paddingRight: 15)
        
        let userInfoStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel, bioLabel])
        userInfoStack.axis = .vertical
        userInfoStack.distribution = .fillProportionally
        userInfoStack.spacing = 3
        
        addSubview(userInfoStack)
        userInfoStack.anchor(top: userImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 10, paddingLeft: 10, paddingRight: 10)
        
        let followStack = UIStackView(arrangedSubviews: [followingLabel, followersLabel])
        followStack.axis = .horizontal
        followStack.spacing = 4
        addSubview(followStack)
        followStack.anchor(top: userInfoStack.bottomAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 10)
        
        addSubview(profileCategory)
        profileCategory.anchor(left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, height: 40)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functionality
    
    func configure() {
        guard let user = user else {return}
        let viewModel = ProfileHeaderViewModel(user: user)
        
        userImageView.sd_setImage(with: user.userImageUrl)
        editProfileButton.setTitle(viewModel.actionButtonTitle, for: .normal)
        
        followersLabel.attributedText = viewModel.followers
        followingLabel.attributedText = viewModel.following
        fullnameLabel.text = user.fullname
        usernameLabel.text = viewModel.usernameText
        bioLabel.text = user.bio
        
    }
}


//MARK: - ProfileCategoryDelegate

extension ProfileHeader: ProfileCategoryDelegate {
    func filterCategory(view: ProfileCategory, index: Int) {
        guard let category = ProfileCategoryOptions(rawValue: index) else {return}
        delegate?.didSelectCategory(category: category)
    }
}
