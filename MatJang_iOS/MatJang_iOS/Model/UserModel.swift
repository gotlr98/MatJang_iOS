//
//  UserModel.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 10/10/24.
//

import Foundation
import UIKit

enum SocialType: String{
    case Kakao, Apple, Guest
}

public struct UserModel{
    
    var email: String
    var socialType: SocialType = .Guest
    var matjip_list: [String: [Matjip]] = [:]
    var review: [String: [String: [Double]]] = [:]
    var following: [String] = []
    var follower: [String] = []
    var block_list: [String] = []
    
    init(email: String, socialType: SocialType) {
        self.email = email
        self.socialType = socialType
    }
    
}
