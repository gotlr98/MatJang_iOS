//
//  MatjipReviewView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 2/18/25.
//

import Foundation
import UIKit
import SnapKit

class MatjipReviewView: UIViewController{
    
    var matjip: Matjip?
    var review: [String: [String:String]]?
    
//    private lazy var place_name = UILabel().then{
//        $0.text = matjip?.place_name
//        $0.font = .systemFont(ofSize: 25, weight: .medium)
//    }
//    
//    private lazy var category = UILabel().then{
//        $0.text = (matjip?.category_name.split(separator: ">"))?.last
//        $0.text = matjip?.category_name
//        $0.font = .systemFont(ofSize: 14, weight: .medium)
//    }
//    
//    private lazy var road_address = UILabel().then{
//        $0.text = matjip?.road_address_name
//        $0.font = .systemFont(ofSize: 13, weight: .medium)
//    }
    
    private lazy var place_name = UILabel().then{
        
        $0.font = .systemFont(ofSize: 13, weight: .medium)
    }
    
    private lazy var review_text = UILabel().then{
        
        $0.font = .systemFont(ofSize: 13, weight: .medium)
    }
    
    override func viewDidLoad(){
        
        self.view.backgroundColor = .white
        
        self.view.addSubview(place_name)
        self.view.addSubview(review_text)
        
        place_name.translatesAutoresizingMaskIntoConstraints = false
        review_text.translatesAutoresizingMaskIntoConstraints = false
        
        
        
        place_name.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
            make.width.equalTo(50)
            make.height.equalTo(50)
        })
        
        review_text.snp.makeConstraints({ make in
            make.centerX.equalTo(self.view.snp.centerX)
            make.top.equalTo(place_name.snp.bottom).offset(20)
            make.width.equalTo(50)
            make.height.equalTo(50)
        })
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.place_name.text = review?.keys as? String ?? "nil"
        self.review_text.text = review?.values as? String ?? "nil"
    }
}
