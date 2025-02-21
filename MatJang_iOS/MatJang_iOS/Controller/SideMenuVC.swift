//
//  SideMenuVC.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 10/8/24.
//

import Foundation
import UIKit

class SideMenuVC: UIViewController{
    
    private lazy var userButton = UIImageView().then{
        $0.image = UIImage(systemName: "person.crop.circle.badge.plus")
        $0.tintColor = .gray
        let tap = UITapGestureRecognizer(target: self, action: #selector(navigateUserPage))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
        
    }
    
    @objc func navigateUserPage(){
        print("tap")
        
        self.present(UserDetailView(), animated: true)
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 20
        self.view.clipsToBounds = true
        
        self.view.backgroundColor = .white.withAlphaComponent(0.7)
        
        self.view.addSubview(userButton)
        userButton.translatesAutoresizingMaskIntoConstraints = false
        userButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
        userButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50).isActive = true
    }
}
