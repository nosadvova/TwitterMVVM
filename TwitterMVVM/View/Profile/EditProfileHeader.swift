
import UIKit

protocol EditProfileHeaderDelegate: AnyObject {
    func changeImage()
}


class EditProfileHeader: UIView {
    
    //MARK: - Properties
    
    private let user: User
    
    weak var delegate: EditProfileHeaderDelegate?
    
     lazy var userImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleToFill
        image.clipsToBounds = true
        image.layer.borderColor = UIColor.white.cgColor
        image.layer.borderWidth = 2.5
        image.setDimensions(width: 90, height: 90)
        image.layer.cornerRadius = 90 / 2
        
        return image
    }()
    
     lazy var changeImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change profile image", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(changeImage), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(frame: .zero)
        
        backgroundColor = .twitterBlue
        
        addSubview(userImageView)
        userImageView.centerX(inView: self, topAnchor: topAnchor, paddingTop: 15)
        userImageView.sd_setImage(with: user.userImageUrl)
        
        addSubview(changeImageButton)
        changeImageButton.anchor(top: userImageView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 5, paddingLeft: 10, paddingRight: 10)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func changeImage() {
        delegate?.changeImage()
    }
    
    //MARK: - Functionality
}
