//
//  AddBookmarkView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 11/21/24.
//

import Foundation
import UIKit
import Then
import SnapKit
import FirebaseFirestore

class AddBookmarkView: UIViewController{
    
    var addBookmarkName: [String] = []
    
    let db = Firestore.firestore()
    
    private lazy var addButton = UIButton().then{
        $0.setTitle("추가하기", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.setImage(UIImage(systemName: "plus.app"), for: .normal)
        $0.addTarget(self, action: #selector(onTouchAddButton), for: .touchUpInside)
    }
    
    private lazy var bookmarkListButton: [UIButton] = []
    
    @objc func onTouchAddButton(){
        let bookmarkAddAlert = UIAlertController(title: "즐겨찾기명을 입력해주세요", message: "", preferredStyle: .alert)
        bookmarkAddAlert.addTextField{ text in
            text.keyboardType = .default
            text.autocapitalizationType = .none
            text.autocorrectionType = .no
        }
        
        let okAction = UIAlertAction(title: "등록", style: .default){ action in
            let textField = bookmarkAddAlert.textFields?.first
            let text = textField?.text ?? ""
            
            self.addBookmarkName.append(text)
            self.view.layoutIfNeeded()
            
            let user_email = UserDefaults.standard.string(forKey: "isAutoLogin")
            
//            self.db.collection("users").document(user_email ?? "").collection("bookmark").document(text).updateData([:])
            self.db.collection("users").document(user_email ?? "").collection("bookmark").document(text).setData([:])
            
            print(text)
            
            self.viewDidLoad()
            
            if(text == ""){
                self.showToast(message: "메시지를 입력해주세요")
                return
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        bookmarkAddAlert.addAction(okAction)
        bookmarkAddAlert.addAction(cancelAction)
        
        self.present(bookmarkAddAlert, animated: true)
    }
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)){

            let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-10, width: 150, height: 35))
            toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
                 toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    
    override func viewDidLoad(){
        self.view.backgroundColor = .white
        
        let user_email = UserDefaults.standard.string(forKey: "isAutoLogin")
        
        Task{
            self.db.collection("users").document(user_email ?? "").collection("bookmark").getDocuments{ (snapshot, err) in
                if let err = err{
                    print(err)
                }
                else{
                    guard let snapshot = snapshot else{return}
                    for document in snapshot.documents{
                        
                        self.addBookmarkName.append(document.documentID)
                        print("await \(document.documentID)")
                    }
                }
            }
        }
                
        self.view.addSubview(addButton)
        
        addButton.snp.makeConstraints({ make in
            make.top.equalTo(self.view.snp.top).offset(20)
            make.centerX.equalTo(self.view.snp.centerX)
        })
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        var count = 0
        
        if(!(self.addBookmarkName.isEmpty)){
            for i in 0..<addBookmarkName.count{
                bookmarkListButton.append(UIButton())
            }
            for te in bookmarkListButton{
                self.view.addSubview(te)
                te.setTitle(addBookmarkName[count], for: .normal)
                te.setTitleColor(.black, for: .normal)
                let gesture = CustomGestureRecognizer(target: self, action: #selector(touchBookmarkListener(gesture: )))
                gesture.touchString = addBookmarkName[count]
                gesture.direction = .up
                te.addGestureRecognizer(gesture)
                
                if(count == 0){
                    te.snp.makeConstraints({ make in
                        make.width.equalTo(self.view.snp.width)
                        make.height.equalTo(50)
                        make.top.equalTo(self.addButton.snp.bottom).offset(10)
                    })
                }
                else{
                    te.snp.makeConstraints({ make in
                        make.width.equalTo(self.view.snp.width)
                        make.height.equalTo(50)
                        make.top.equalTo(self.bookmarkListButton[count-1].snp.bottom).offset(10)
                    })
                }
                
                
                count += 1
            }
            
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func touchBookmarkListener(gesture: CustomGestureRecognizer){
        print(gesture.touchString)
    }
}

class CustomGestureRecognizer: UISwipeGestureRecognizer{
    var touchString: String?
}
