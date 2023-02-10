//
//  NotificationCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 09.02.2023.
//

import UIKit

protocol NotificationCellDelegate: AnyObject {
    func profileImageTapped(cell: NotificationCell)
    func followTapped(cell: NotificationCell)
}

class NotificationCell: UITableViewCell {

    //MARK: - Properties
    
    weak var delegate: NotificationCellDelegate?
    
    var notification: Notification? {
        didSet {configure()}
    }
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.setDimensions(width: 35, height: 35)
        image.layer.cornerRadius = 35 / 2
        image.backgroundColor = .twitterBlue
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(userImageTapped))
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(tap)
        
        return image
    }()
    
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 2
        label.text = "Text notification"
        
        return label
    }()
    
    private lazy var followButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.borderColor = UIColor.twitterBlue.cgColor
        button.layer.borderWidth = 1
        button.setDimensions(width: 70, height: 30)
        button.layer.cornerRadius = 30 / 2
        
        button.addTarget(self, action: #selector(followTapped), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let stack = UIStackView(arrangedSubviews: [userImageView, notificationLabel])
        contentView.addSubview(stack)
        
        stack.axis = .horizontal
        stack.spacing = 10
        stack.alignment = .center
        stack.centerY(inView: self)
        stack.anchor(left: leftAnchor, right: rightAnchor, paddingLeft: 10, paddingRight: 10)
        
        contentView.addSubview(followButton)
        followButton.centerY(inView: self)
        followButton.anchor(right: rightAnchor, paddingRight: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func userImageTapped() {
        delegate?.profileImageTapped(cell: self)
    }
    
    @objc func followTapped() {
        delegate?.followTapped(cell: self)
    }
    
    //MARK: - Functionality
    
    private func configure() {
        guard let notification = notification else {return}
        let viewModel = NotificationViewModel(notification: notification)
        
        userImageView.sd_setImage(with: viewModel.userImageUrl)
        notificationLabel.attributedText = viewModel.notificationText
        
        followButton.isHidden = viewModel.hideFollowButton
        followButton.setTitle(viewModel.followButtonText, for: .normal)
    }
}
