//
//  MatjipReviewView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 2/18/25.
//

import Foundation
import UIKit

class MatjipReviewView: UIViewController{
    
    var matjip: Matjip?
    var review: [String: [String:String]]?
    
    override func viewDidLoad(){
        
        self.view.backgroundColor = .white
    }
}
