//
//  ExploreVC.swift
//  TwitterMVVM
//
//  Created by Vova Novosad on 28.01.2023.
//

import UIKit

class ExploreVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        
        view.backgroundColor = .white
        
        navigationItem.title = "Explore"
    }

}
