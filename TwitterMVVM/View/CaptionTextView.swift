//
//  CaptionTextView.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 02.02.2023.
//

import UIKit

class CaptionTextView: UITextView {
    
    //MARK: - Properties
    
    let placeholder: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        label.text = "What's up?"
        
        return label
    }()
    
    //MARK: - Selectors
    
    @objc func handleTextInputChanged() {
        placeholder.isHidden = !text.isEmpty
    }
    
    //MARK: - Lifecycle

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        addSubview(placeholder)
        placeholder.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        backgroundColor = .white
        font = UIFont.systemFont(ofSize: 16)
        isScrollEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextInputChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
