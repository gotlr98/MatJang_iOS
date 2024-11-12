//
//  UserDetailView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 10/15/24.
//

import Foundation
import UIKit

class UserDetailView: UIViewController{
    
    override func viewDidLoad() {
        self.view.backgroundColor = .black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        print("view disappear")
    }
}
