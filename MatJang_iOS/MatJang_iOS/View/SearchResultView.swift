//
//  SearchResultView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 11/1/24.
//

import Foundation
import UIKit

class SearchResultView: UIViewController{
    
    var search_list: [Matjip] = []
    
    private lazy var btn = UIImageView().then{
        $0.image = UIImage(systemName: "magnifyingglass")
        $0.tintColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(temp))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
        
    }
    override func viewDidLoad() {
        self.view.addSubview(btn)
        self.view.backgroundColor = .white
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
    }
    
    @objc func temp(){
        for li in search_list{
            print(li.place_name)
        }
    }
}
