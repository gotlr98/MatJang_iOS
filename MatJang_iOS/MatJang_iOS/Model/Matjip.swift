//
//  Matjip.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 10/10/24.
//

import Foundation
import UIKit

public struct MatjipList: Codable{
    
    var documents: [Matjip]
}

//public struct MatjipResponse: Codable{
//    
//    var documents: [String: Any]?
//    
//}
public struct Matjip: Codable{

    var place_name: String?
    var x: String?
    var y: String?
    var address_name: String?
    var category_name: String?
    
}
