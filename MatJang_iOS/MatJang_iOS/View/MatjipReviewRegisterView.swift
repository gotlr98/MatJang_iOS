//
//  MatjipReviewView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 2/11/25.
//

import Foundation
import UIKit
import Cosmos
import SnapKit

import FirebaseFirestore

class MatjipReviewRegisterView: UIViewController{
    
    var matjip: Matjip?
    
    let db = Firestore.firestore()
    
    let rate = CosmosView()
    private lazy var reviewText = UITextField().then{
        $0.placeholder = "리뷰를 남겨주세요"
        $0.borderStyle = .roundedRect
    }
    
    private lazy var registerBtn = UIButton().then{
        $0.setTitle("등록하기", for: .normal)
        $0.backgroundColor = .lightGray
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(register))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
    
    @objc func register(){
        
        let rate = Int(self.rate.rating)
        let review = self.reviewText.text ?? ""
        
        let user_email = UserDefaults.standard.string(forKey: "isAutoLogin")
        
        
        self.db.collection("users").document(user_email ?? "").collection("review").document(matjip?.place_name ?? "").setData(["rate":rate, "review": review])
        
        self.db.collection("review").document(matjip?.place_name ?? "").setData(["users": user_email ?? "", "rate": rate, "review": review], merge: true)
    }
 
    
    override func viewDidLoad(){
        self.view.backgroundColor = .white
    
        rate.rating = 5
        
        self.view.addSubview(rate)
        
        rate.translatesAutoresizingMaskIntoConstraints = false
        rate.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        rate.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 20).isActive = true
        
        rate.snp.makeConstraints({make in
            make.centerY.equalTo(self.view.snp.centerY)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        
        self.view.addSubview(reviewText)
        
        
        reviewText.snp.makeConstraints({ make in
            make.top.equalTo(rate.snp.bottom).offset(50)
            make.centerX.equalTo(self.view.center)
            make.width.equalTo(self.view.snp.width).dividedBy(3)
            make.height.equalTo(100)
        })
        
        self.view.addSubview(registerBtn)
        
        registerBtn.snp.makeConstraints({make in
            make.top.equalTo(reviewText.snp.bottom).offset(50)
            make.centerX.equalTo(self.view.center)
            make.width.equalTo(80)
            make.height.equalTo(50)
        })
    }
}
