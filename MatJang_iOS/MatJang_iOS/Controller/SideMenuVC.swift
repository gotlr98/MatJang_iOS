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
    
    private lazy var userButton = UIImageView().then{
        $0.image = UIImage(systemName: "person.crop.circle.badge")
        $0.tintColor = .gray
        let tap = UITapGestureRecognizer(target: self, action: #selector(navigateUserPage))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
        
    }
    
    private lazy var user_email = UILabel()
    
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
            make.right.equalTo(self.view.snp.right).offset(40)
            make.top.equalTo(self.view.snp.top).offset(60)
            make.width.equalTo(30)
            make.height.equalTo(30)
        })
        
        var get_user_email: String = UserDefaults.standard.string(forKey: "isAutoLogin") ?? ""
        
        if(get_user_email != ""){
            let user_email_text = get_user_email.split(separator: "&").first
            
            let trans_email = user_email_text
            
            self.user_email.text = user_email_text as? String ?? ""
            
            print(user_email_text)
        }
        
        
        
        
    }
}
