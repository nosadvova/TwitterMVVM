//
//  ActionSheetLauncher.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 07.02.2023.
//

import UIKit

private let cellIdentifier = "cell"

protocol ActionSheetLauncherDelegate: AnyObject {
    func didSelectOption(option: ActionSheetOptions)
}

class ActionSheetLauncher: NSObject{
    
    //MARK: - Properties
    private let user: User
    private let tableView = UITableView()
    private var window: UIWindow?
    private var tableViewHeight: CGFloat?
    
    private lazy var viewModel = ActionSheetViewModel(user: user)
    
    weak var delegate: ActionSheetLauncherDelegate?
    
    
    private lazy var darkView: UIView = {
        let view = UIView()
        view.alpha = 0
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissActionSheet))
        view.addGestureRecognizer(tap)
        
        return view
    }()
    
    private lazy var footerView: UIView = {
        let view = UIView()
        view.addSubview(cancelButton)
        
        cancelButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        cancelButton.anchor(left: view.leftAnchor, right: view.rightAnchor, paddingLeft: 12, paddingRight: 12)
        cancelButton.centerY(inView: view)
        cancelButton.layer.cornerRadius = 50 / 2
        
        return view
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.backgroundColor = .systemGroupedBackground
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(cancelPressed), for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init()
        
        configureTableView()
    }
    
    //MARK: - Selectors
    
    @objc func dismissActionSheet() {
        UIView.animate(withDuration: 0.5) {
            self.darkView.alpha = 0
            self.tableView.frame.origin.y += 300
        }
    }
    
    @objc func cancelPressed() {
        
    }
    
    //MARK: - Functionality
    
    func showTableView(shouldShow: Bool) {
        guard let window = window else {return}
        guard let height = tableViewHeight else {return}
        let y = shouldShow ? window.frame.height - height : window.frame.height
        tableView.frame.origin.y = y
    }
    
    func show() {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {return}
        self.window = window
        
        window.addSubview(darkView)
        darkView.frame = window.frame
        
        window.addSubview(tableView)
        self.tableViewHeight = CGFloat(viewModel.options.count * 60) + 100
        tableView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: tableViewHeight!)
        
        UIView.animate(withDuration: 0.5) {
            self.darkView.alpha = 1
            self.showTableView(shouldShow: true)
        }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(ActionSheetCell.self, forCellReuseIdentifier: cellIdentifier)
        
        tableView.rowHeight = 60
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 5
        tableView.isScrollEnabled = false
    }
}

//MARK: - UITableViewDataSource

extension ActionSheetLauncher: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! ActionSheetCell
        cell.option = viewModel.options[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = viewModel.options[indexPath.row]
        
        UIView.animate(withDuration: 0.5) {
            self.darkView.alpha = 0
            self.showTableView(shouldShow: false)
        }
        delegate?.didSelectOption(option: option)
    }
}

//MARK: - UITableViewDelegate

extension ActionSheetLauncher: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 60
    }
}

