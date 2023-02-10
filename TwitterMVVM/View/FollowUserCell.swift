//
//  FollowUserCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 05.02.2023.
//

import UIKit

class FollowUserCell: UITableViewCell {
    
    //MARK: - Properties
    
     var user: User? {
        didSet {configure()}
    }
    
    private lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 4
        image.setDimensions(width: 45, height: 45)
        image.layer.cornerRadius = 45 / 2
        image.backgroundColor = .gray
        
        return image
    }()
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = "Name"
        
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "username"
        
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(userImageView)
        userImageView.centerY(inView: self, leftAnchor: leftAnchor)
        
        let labelsStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel])
        addSubview(labelsStack)
        labelsStack.axis = .vertical
        labelsStack.spacing = 3
        labelsStack.centerY(inView: self, leftAnchor: userImageView.rightAnchor, paddingLeft: 10)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    //MARK: - Functionality
    
    private func configure() {
        guard let user = user else {return}
        
        userImageView.sd_setImage(with: user.userImageUrl)
        fullnameLabel.text = user.fullname
        usernameLabel.text = user.username
    }


}
