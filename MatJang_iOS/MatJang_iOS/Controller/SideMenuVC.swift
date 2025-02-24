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
        
        userButton.snp.makeConstraints({ make in
            make.left.equalTo(self.view.snp.left).offset(40)
            make.top.equalTo(self.view.snp.top).offset(30)
            make.width.equalTo(50)
            make.height.equalTo(50)
        })
    }
}
