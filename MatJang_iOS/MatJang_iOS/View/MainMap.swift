//
//  MainMap.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 8/7/24.
//

import Foundation
import UIKit
import KakaoMapsSDK

class MainMap: MainMapViewController {
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 126.978365, latitude: 37.566691)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        
        mapController?.addView(mapviewInfo)
    }
    
}
