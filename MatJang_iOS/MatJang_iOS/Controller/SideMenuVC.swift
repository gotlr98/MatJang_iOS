//
//  SideMenuVC.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 10/8/24.
//

import Foundation
import UIKit
import SnapKit

class SideMenuVC: UIViewController{
    
    var email: String?
    
    private lazy var userButton = UIImageView().then{
        $0.image = UIImage(systemName: "person.crop.circle.badge")
        $0.tintColor = .gray
        let tap = UITapGestureRecognizer(target: self, action: #selector(navigateUserPage))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
        
    }
    
    private lazy var user_email = UILabel().then{
        $0.text = email
        $0.font = .systemFont(ofSize: 14, weight: .medium)
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
        
        userButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left).offset(40)
            make.top.equalTo(self.view.snp.top).offset(60)
            make.width.equalTo(30)
            make.height.equalTo(30)
        })
        
        
        
        self.view.addSubview(user_email)
        
        user_email.translatesAutoresizingMaskIntoConstraints = false
        user_email.snp.makeConstraints({ make in
            make.top.equalTo(self.userButton.snp.bottom).offset(50)
            make.width.equalTo(100)
            make.height.equalTo(50)
        })
        
        print(self.email)
        
        
    }
}
