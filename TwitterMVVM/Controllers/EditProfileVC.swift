//
//  EditProfileVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 11.02.2023.
//

import UIKit

private let cellIdentifier = "cell"

protocol EditProfileControllerDelegate: AnyObject {
    func controller(controller: EditProfileVC, updateUser: User)
    func handleLogOut()
}

class EditProfileVC: UITableViewController {
    
    //MARK: - Properties
    
    weak var delegate: EditProfileControllerDelegate?
    
    private var user: User
    private lazy var headerView = EditProfileHeader(user: user)
    private lazy var footerView = EditProfileFooter()
    private let imagePicker = UIImagePickerController()
    
    private var userInfoChanged = false
    private var userImageChanged: Bool {
        return selectedImage != nil
    }
    
    private var selectedImage: UIImage? {
        didSet {headerView.userImageView.image = selectedImage}
    }
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        headerView.delegate = self
        footerView.delegate = self
        
        configureNavigationBar()
        configureTableView()
        imagePickerConfigure()
    }
    
    init(user: User) {
        self.user = user
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Selectors
    
    @objc func cancel() {
        dismiss(animated: true)
    }
    
    @objc func saveChanges() {
        view.endEditing(true)
        guard userImageChanged || userInfoChanged else {return}
        saveUserData()
    }
    
    //MARK: - API
    
    private func saveUserData() {
        
        if userImageChanged && !userInfoChanged {
           updateUserImage()
        } else if !userImageChanged && userInfoChanged {
            UserService.shared.saveUserData(user: user) {error, reference in
                self.delegate?.controller(controller: self, updateUser: self.user)
            }
        } else if userImageChanged && userInfoChanged {
            UserService.shared.saveUserData(user: user) { error, reference in
                self.updateUserImage()
            }
        }
    }
    
    private func updateUserImage() {
        guard let image = selectedImage else {return}
        
        UserService.shared.updateUserImage(image: image) { url in
            self.user.userImageUrl = url
            self.delegate?.controller(controller: self, updateUser: self.user)
        }
    }

    //MARK: - Functionality
    
    private func configureNavigationBar() {
        if #available(iOS 15.0, *) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .twitterBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        } else {
        navigationController?.navigationBar.barTintColor = .twitterBlue
        }
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.isTranslucent = false
        
        navigationItem.title = "Edit profile"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveChanges))
    }
    
    private func configureTableView() {
        tableView.tableHeaderView = headerView
        headerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 170)
        
        tableView.tableFooterView = footerView
        footerView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 50)
        
        tableView.register(EditProfileCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func imagePickerConfigure() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
    }
}

//MARK: - UITableViewDataSource

extension EditProfileVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return EditProfileOptions.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EditProfileCell
        
        guard let option = EditProfileOptions(rawValue: indexPath.row) else {return cell}
        
        cell.delegate = self
        cell.viewModel = EditEditProfileViewModel(user: user, option: option)
        return cell
    }
}

//MARK: - UITableViewDelegate

extension EditProfileVC {
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let option = EditProfileOptions(rawValue: indexPath.row) else {return 0}
        return option == .bio ? 100 : 50
    }
}

//MARK: - UIImagePickerControllerDelegate

extension EditProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else {return}
        
        selectedImage = image
        dismiss(animated: true)
    }
}

//MARK: - EditProfileHeaderDelegate

extension EditProfileVC: EditProfileHeaderDelegate {
    func changeImage() {
        present(imagePicker, animated: true)
    }
}

//MARK: - EditProfileCellDelegate

extension EditProfileVC: EditProfileCellDelegate {
    func updateUserInfo(cell: EditProfileCell) {
        guard let viewModel = cell.viewModel else {return}
        
        userInfoChanged = true
        navigationItem.rightBarButtonItem?.isEnabled = true
        
        switch viewModel.option {
        case .fullname:
            guard let value = cell.infoTextField.text else {return}
            user.fullname = value
        case .username:
            guard let value = cell.infoTextField.text else {return}
            user.username = value
        case .bio:
            user.bio = cell.bioTextView.text
        }
    }
}

//MARK: - EditProfileFooterDelegate

extension EditProfileVC: EditProfileFooterDelegate {
    func logOut() {
        let alert = UIAlertController(title: nil, message: "Are you sure?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Log Out", style: .default, handler: { alert in
            self.dismiss(animated: true) {
                self.delegate?.handleLogOut()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
}
