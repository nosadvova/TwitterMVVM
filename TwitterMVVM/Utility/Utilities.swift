
import UIKit

class Utilities {
    
    func inputContainerView(image: UIImage, textField: UITextField) -> UIView {
        let view = UIView()
        view.heightAnchor.constraint(equalToConstant: 50).isActive = true
        let imageView = UIImageView(image: image)
        
        view.addSubview(imageView)
        imageView.anchor(left: view.leftAnchor, bottom: view.bottomAnchor, paddingLeft: 10, paddingBottom: 10, width: 24, height: 24)
        
        view.addSubview(textField)
        textField.textColor = .white
        textField.autocapitalizationType = UITextAutocapitalizationType.none
        textField.autocorrectionType = UITextAutocorrectionType.no
        textField.anchor(left: imageView.rightAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingLeft: 10, paddingBottom: 10)
        
        let dividerView = UIView()
        view.addSubview(dividerView)
        dividerView.backgroundColor = .white
        dividerView.anchor(top: textField.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 5, paddingLeft: 10, paddingRight: 10, height: 0.75)
        
        return view
    }
    
    func textFieldSettings(_ placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.textColor = .white
        textField.font?.withSize(16)
        textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return textField
    }
    
    func attributedButton(firstPart: String, secondPart: String) -> UIButton {
        let button = UIButton()
        let attributedTitle = NSMutableAttributedString(string: firstPart, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        
        attributedTitle.append(NSMutableAttributedString(string: secondPart,attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }
}

