//
//  LoginVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 29.01.2023.
//

import UIKit

class LoginVC: UIViewController {
    
    //MARK: - Properties
    
    private let logoImageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: "TwitterLogo"))
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        return image
    }()
    
    private lazy var emailContainerView: UIView = {
        let email = Utilities().inputContainerView(image: UIImage(named: "mail_unselected")!, textField: emailTextField)
        
        return email
    }()
    
    private lazy var passwordContainerView: UIView = {
        let password = Utilities().inputContainerView(image: UIImage(named: "ic_lock_outline_white_2x")!, textField: passwordTextField)
        
        return password
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
    
    private lazy var logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.twitterBlue, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(loginPressed), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var signUnButton: UIButton = {
        let button = Utilities().attributedButton(firstPart: "Don't have an account?", secondPart: " Sign up")
        button.addTarget(self, action: #selector(signUpPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: - Selectors
    
    @objc private func loginPressed() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
                
        AuthSevice.shared.logInUser(email: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: logInUser error", error.localizedDescription)
                return
            }
            
            guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {return}
            guard let tab = window.rootViewController as? MainTabBarVC else {return}
            
            tab.authenticateUserAndConfigureUI()
            self.dismiss(animated: true)
        }
    }
    
    @objc private func signUpPressed() {
        let registrationVC = RegisterVC()
        navigationController?.pushViewController(registrationVC, animated: true)
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    
    //MARK: - Functionality

    func configureUI() {
        view.backgroundColor = .twitterBlue
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(width: 100, height: 100)
        logoImageView.centerX(inView: view, topAnchor: view.safeAreaLayoutGuide.topAnchor)
        
        let stackView = UIStackView(arrangedSubviews: [emailContainerView, passwordContainerView])
        
        view.addSubview(stackView)
        stackView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 10, paddingRight: 10)
        stackView.axis = .vertical
        stackView.spacing = 10
        
        
        view.addSubview(logInButton)
        logInButton.anchor(top: stackView.bottomAnchor, paddingTop: 30, width: 300, height: 50)
        logInButton.centerX(inView: view)
        
        view.addSubview(signUnButton)
        signUnButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor)
        
    }

}
