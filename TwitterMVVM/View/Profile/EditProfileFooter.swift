//
//  EditProfileFooter.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 13.02.2023.
//

import UIKit

protocol EditProfileFooterDelegate: AnyObject {
    func logOut()
}

class EditProfileFooter: UIView {
    
    //MARK: - Properties
    
    weak var delegate: EditProfileFooterDelegate?
    
    private lazy var logOutButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log Out", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.addTarget(self, action: #selector(logOutPressed), for: .touchUpInside)
        button.backgroundColor = .red
        button.setDimensions(width: 150, height: 40)
        button.layer.cornerRadius = 40 / 2
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(logOutButton)
        logOutButton.centerX(inView: self, topAnchor: topAnchor, paddingTop: 30)        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc private func logOutPressed() {
        delegate?.logOut()
    }
    
    //MARK: - Functionality



}
