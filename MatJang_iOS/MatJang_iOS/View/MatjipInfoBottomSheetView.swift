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
        $0.font = .systemFont(ofSize: 25, weight: .medium)
    }
    
    private lazy var category = UILabel().then{
//        $0.text = (matjip?.category_name.split(separator: ">"))?.last
        $0.text = matjip?.category_name
        $0.font = .systemFont(ofSize: 14, weight: .medium)
    }
    
    private lazy var road_address = UILabel().then{
        $0.text = matjip?.address_name
        $0.font = .systemFont(ofSize: 13, weight: .medium)
    }

    private lazy var bookmark = UIImageView().then{
        $0.image = UIImage(systemName: "bookmark.fill")
        $0.tintColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bookmarkTapped))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
    
    @objc func bookmarkTapped(){
        let vc = AddBookmarkView()
        vc.modalPresentationStyle = .pageSheet
        let multiplier = 1.0
        let fraction = UISheetPresentationController.Detent.custom { context in
            // height is the view.frame.height of the view controller which presents this bottom sheet
            self.view.frame.height * multiplier
        }
        if let sheet = vc.sheetPresentationController{
            sheet.detents = [fraction]
        }
        self.present(vc, animated: true)
    }
    
    override func viewDidLoad(){
        
        view.addSubview(place_name)
        view.addSubview(category)
        view.addSubview(road_address)
        view.addSubview(bookmark)
        
        self.view.backgroundColor = .white
        
        place_name.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(20)
            make.left.equalTo(self.view.snp.left).offset(20)
        })
        
        category.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(22)
            make.left.equalTo(self.place_name.snp.right).offset(10)
        })
        
        road_address.snp.makeConstraints({ make in
            make.top.equalTo(self.place_name.snp.bottom).offset(18)
            make.left.equalTo(self.view.snp.left).offset(22)
        })
        
        bookmark.snp.makeConstraints({make in
            make.bottom.equalTo(self.view.snp.bottom).offset(-50)
            make.right.equalTo(self.view.snp.right).offset(-50)
            make.width.equalTo(30)
            make.height.equalTo(30)
        })
    }
}
