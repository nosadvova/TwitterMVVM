//
//  ProfileCategory.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 03.02.2023.
//

import UIKit

private let cellIdentifier = "cell"

protocol ProfileCategoryDelegate: AnyObject {
    func filterCategory(view: ProfileCategory, index: Int)
}

class ProfileCategory: UIView {
    
    //MARK: - Properties
    
    weak var delegate: ProfileCategoryDelegate?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.backgroundColor = .twitterBlue
        collectionView.delegate = self
        collectionView.dataSource = self

        return collectionView
    }()
    
    private let underlineView: UIView = {
        let view = UIView()
        view.backgroundColor = .twitterBlue
        
        return view
    }()
    
    //MARK: - Lifecycle
    
    override func layoutSubviews() {
        addSubview(underlineView)
        underlineView.anchor(left: leftAnchor, bottom: bottomAnchor, width: frame.width / 3, height: 2.5)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(ProfileCategoryCell.self, forCellWithReuseIdentifier: cellIdentifier)
        
        let selectedCategory = IndexPath(row: 0, section: 0)
        collectionView.selectItem(at: selectedCategory, animated: true, scrollPosition: .left)
        
        addSubview(collectionView)
        collectionView.addConstraintsToFillView(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functionality
    
}

//MARK: - UICollectionView Delegates

extension ProfileCategory: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ProfileCategoryOptions.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ProfileCategoryCell
        let category = ProfileCategoryOptions(rawValue: indexPath.row)
        cell.category = category

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.filterCategory(view: self, index: indexPath.row)
        
        let cell = collectionView.cellForItem(at: indexPath)
        
        let xPosition = cell?.frame.origin.x ?? 0
        
        UIView.animate(withDuration: 0.3) {
            self.underlineView.frame.origin.x = xPosition
        }
    }
}

extension ProfileCategory: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let categories = CGFloat(ProfileCategoryOptions.allCases.count)
        return CGSize(width: frame.width / categories, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
