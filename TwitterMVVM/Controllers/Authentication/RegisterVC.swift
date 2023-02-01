

import UIKit
import FirebaseCore
import FirebaseAuth
import Firebase
import FirebaseDatabase

class RegisterVC: UIViewController {

    //MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var userImage: UIImage?
    
    
    private lazy var addPhoto: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "plus_photo"), for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(addPhotoPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var emailContainerView: UIView = {
        let email = Utilities().inputContainerView(image: UIImage(named: "mail_unselected")!, textField: emailTextField)
        
        return email
    }()
    
    private lazy var passwordContainerView: UIView = {
        let password = Utilities().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x")!, textField: passwordTextField)
        
        return password
    }()
    
    private lazy var fullnameContainerView: UIView = {
        let fullName = Utilities().inputContainerView(image: UIImage(named: "ic_person_outline_white_2x")!, textField: fullnameTextField)
        
        return fullName
    }()
    
    private lazy var usernameContainerView: UIView = {
        let username = Utilities().inputContainerView(image: UIImage(named: "ic_person_outline_white_2x")!, textField: usernameTextField)
        
        return username
    }()
    
    private lazy var emailTextField: UITextField = {
        let textField = Utilities().textFieldSettings("Email")
        
        return textField
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = Utilities().textFieldSettings("Password")
        textField.isSecureTextEntry = true
        
        return textField
    }()
    
    private lazy var fullnameTextField: UITextField = {
        let textField = Utilities().textFieldSettings("Full Name")
        
        return textField
    }()
    
    private lazy var usernameTextField: UITextField = {
        let textField = Utilities().textFieldSettings("Username")
        
        return textField
    }()
    
    private lazy var haveAnAccountButton: UIButton = {
        let button = Utilities().attributedButton(firstPart: "Already have an account?", secondPart: " Log in")
        button.addTarget(self, action: #selector(alreadyHavePressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var sighUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Selectors
    
    @objc private func alreadyHavePressed() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func addPhotoPressed() {
        present(imagePicker, animated: true)
    }
    
    @objc private func signUpPressed() {
        guard let userImage = userImage else {return}
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        guard let fullname = fullnameTextField.text else {return}
        guard let username = usernameTextField.text else {return}
        
        let credentials = AuthCredentials(email: email, password: password, fullname: fullname, username: username, userImage: userImage)
        
        AuthSevice.shared.registerUser(credentials: credentials) { error, reference in
            if let error = error {
                print("DEBUG: registerUser error", error.localizedDescription)
                return
            }
            
            guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {return}
            guard let tab = window.rootViewController as? MainTabBarVC else {return}
            
            tab.authenticateUserAndConfigureUI()
            self.dismiss(animated: true)
        }
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    //MARK: - Functionality
    
    func configureUI() {
        view.backgroundColor = .twitterBlue
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        view.addSubview(addPhoto)
        addPhoto.anchor(width: 150, height: 150)
        addPhoto.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView,
                                                       passwordContainerView,
                                                       fullnameContainerView,
                                                       usernameContainerView])
        view.addSubview(stackView)
        stackView.anchor(top: addPhoto.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingRight: 10)
        stackView.axis = .vertical
        stackView.spacing = 10
        
        view.addSubview(sighUpButton)
        sighUpButton.anchor(top: stackView.bottomAnchor, paddingTop: 30, width: 300, height: 50)
        sighUpButton.centerX(inView: view)
        
        view.addSubview(haveAnAccountButton)
        haveAnAccountButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
    }

}

//MARK: - UIImagePickerControllerDelegate

extension RegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.editedImage] as? UIImage else {return}
        userImage = pickedImage
        
        addPhoto.setImage(pickedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        addPhoto.layer.cornerRadius = 150 / 2
        addPhoto.layer.masksToBounds = true
        dismiss(animated: true)
    }
}
