//
//  ActionSheetCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 07.02.2023.
//

import UIKit

class ActionSheetCell: UITableViewCell {
    
    //MARK: - Properties
    
    var option: ActionSheetOptions? {
        didSet {configure()}
    }
    
    private let optionImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.setDimensions(width: 35, height: 35)
        image.image = UIImage(named: "twitter_logo_blue")
        return image
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "test"
        
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(optionImageView)
        optionImageView.centerY(inView: self)
        optionImageView.anchor(left: leftAnchor, paddingLeft: 10)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: self)
        titleLabel.anchor(left: optionImageView.rightAnchor, paddingLeft: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functionality
    
    private func configure() {
        titleLabel.text = option?.description
    }


}
