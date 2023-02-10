//
//  ProfileCategoryCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 03.02.2023.
//

import UIKit

class ProfileCategoryCell: UICollectionViewCell {
    
    //MARK: - Properties
    
    var category: ProfileCategoryOptions! {
        didSet {titleLabel.text = category.description}
    }
    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "text"
        
        return label
    }()
    
    
    override var isSelected: Bool {
        didSet {
            titleLabel.font = isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 14)
            titleLabel.textColor = isSelected ? UIColor.twitterBlue : UIColor.lightGray
        }
    }
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addSubview(titleLabel)
        titleLabel.center(inView: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
