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
import FirebaseFirestore

class MatjipInfoBottomSheetView: UIViewController{
    
    var matjip: Matjip?
    var isBookmarked: [String:Bool]?
    var review: [String:[String:String]]? = [:]
    
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
        $0.text = matjip?.road_address_name
        $0.font = .systemFont(ofSize: 13, weight: .medium)
    }

    private lazy var bookmark = UIImageView().then{
//        $0.image = UIImage(systemName: "bookmark.fill")
        $0.tintColor = .gray
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(bookmarkTapped))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
    
    @objc func bookmarkTapped(){
        let vc = AddBookmarkView()
        vc.modalPresentationStyle = .pageSheet
        vc.select_matjip = self.matjip
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        
        if (self.review == nil){
            print("review nil \(self.review)")
            let vc = MatjipReviewRegisterView()
            
            vc.matjip = self.matjip
            
            self.present(vc, animated: true)
        }
        
        else{
            print("not nil \(self.review)")
            let vc = MatjipReviewView()
            
            vc.matjip = self.matjip
            vc.review = self.review
            
            self.present(vc, animated: true)
            
        }
        
    }
    
    override func viewDidLoad(){
        
        view.addSubview(place_name)
        view.addSubview(category)
        view.addSubview(road_address)
        view.addSubview(bookmark)
        
        let db = Firestore.firestore()
        let user_email = UserDefaults.standard.string(forKey: "isAutoLogin")
        
        Task{
            await db.collection("users").document(user_email ?? "").collection("bookmark").getDocuments{ (snapshot, err) in
                if let err = err{
                    print(err)
                }
                else{
                    guard let snapshot = snapshot else{return}
                    for document in snapshot.documents{
                        
                        if(document.documentID == self.matjip?.place_name){
                            self.bookmark.image = UIImage(systemName: "bookmark.fill")
                        }
                        else{
                            self.bookmark.image = UIImage(systemName: "person.crop.circle.fill.badge.checkmark")
                        }
                    }
                }
            }
        }
        
        
        
        self.view.backgroundColor = .white
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        self.view.addGestureRecognizer(tap)
        
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
        
        Task{
            await db.collection("users").document(user_email ?? "").collection("review").getDocuments{ (snapshot, err) in
                if let err = err{
                    print(err)
                }
                else{
                    guard let snapshot = snapshot else{return}
                    for document in snapshot.documents{
                        
                        let data = document.data()
                        self.review?[document.documentID] = ["rate": data["rate"] as? String ?? "", "review": data["review"] as? String ?? ""]
                        
                        
                    }
                }
            }
        }
    }
}
