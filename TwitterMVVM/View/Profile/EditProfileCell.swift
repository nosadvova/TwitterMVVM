//
//  EditProfileCell.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 11.02.2023.
//

import UIKit

protocol EditProfileCellDelegate: AnyObject {
    func updateUserInfo(cell: EditProfileCell)
}

class EditProfileCell: UITableViewCell {
    
    //MARK: - Properties
    
    weak var delegate: EditProfileCellDelegate?
    
    var viewModel: EditEditProfileViewModel? {
        didSet {configure()}
    }
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        
        return label
    }()
    
     lazy var infoTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.borderStyle = .none
        textField.textAlignment = .left
        textField.textColor = .twitterBlue
        textField.addTarget(self, action: #selector(updateUserInfo), for: .editingDidEnd)
        
        return textField
    }()
    
    let bioTextView: InputTextView = {
        let label = InputTextView()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .twitterBlue
        label.placeholder.text = "Bio"
        
        return label
    }()
    
    //MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        selectionStyle = .none
        
        contentView.addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 15, width: 100)
        
        contentView.addSubview(infoTextField)
        infoTextField.anchor(top: topAnchor, left: titleLabel.rightAnchor, right: rightAnchor, paddingTop: 8, paddingRight: 10)
        
        contentView.addSubview(bioTextView)
        bioTextView.anchor(top: topAnchor, left: titleLabel.rightAnchor, right: rightAnchor, paddingTop: 2, paddingRight: 10)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateUserInfo), name: UITextView.textDidEndEditingNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func updateUserInfo() {
        delegate?.updateUserInfo(cell: self)
    }
    
    //MARK: - Functionality

    private func configure() {
        guard let viewModel = viewModel else {return}
        
        infoTextField.text = viewModel.optionValue
        infoTextField.isHidden = viewModel.shouldHideTextField
        
        titleLabel.text = viewModel.titleText
        
        bioTextView.text = viewModel.optionValue
        bioTextView.isHidden = viewModel.shouldHideTextView
        bioTextView.placeholder.isHidden = viewModel.shouldHideBio

    }
}
