//
//  Matjip.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 10/10/24.
//

import Foundation
import UIKit

public struct MatjipList: Codable{
    
    var matjipList: [Matjip]
}
public struct Matjip: Codable{
    
    var place_name: String?
    var x: String?
    var y: String?
    var address_name: String?
    var category_name: String?
    
}
