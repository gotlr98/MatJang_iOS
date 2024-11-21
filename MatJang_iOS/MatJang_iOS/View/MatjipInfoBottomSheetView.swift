//
//  MatjipInfoBottomSheetView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 11/15/24.
//

import Foundation
import UIKit
import Then
import SnapKit

class MatjipInfoBottomSheetView: UIViewController{
    
    var matjip: Matjip?
    
    private lazy var place_name = UILabel().then{
        $0.text = matjip?.place_name
        $0.font = .systemFont(ofSize: 20, weight: .medium)
    }
    
    private lazy var category = UILabel().then{
        $0.text = matjip?.category_name
        $0.font = .systemFont(ofSize: 15, weight: .medium)
    }
    
    private lazy var road_address = UILabel().then{
        $0.text = matjip?.address_name
        $0.font = .systemFont(ofSize: 13, weight: .medium)
    }
    
    override func viewDidLoad(){
        
        view.addSubview(place_name)
        view.addSubview(category)
        view.addSubview(road_address)
        
        self.view.backgroundColor = .white
        
        place_name.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp_topMargin)
        })
        
//        category.snp.makeConstraints({ make in
//            make.top.equalTo(self.view.snp_topMargin)
//        })
//        
//        road_address.snp.makeConstraints({ make in
//            make.top.equalTo(self.view.snp_topMargin)
//        })
//        
    }
}
