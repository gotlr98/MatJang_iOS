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
    
    var emailString: String?
    
    override func addViews() {
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
        
        mapController?.addView(mapviewInfo)
    }
    
    override func viewInit(viewName: String) {
        print("ok")
        
        let mapView = mapController?.getView("mapview") as! KakaoMap
        
        _cameraStoppedHandler = mapView.addCameraStoppedEventHandler(target: self, handler: MainMapViewController.onCameraStopped)

        createLabelLayer()
        createPoiStyle()
//        createPois()
    }
    
    
    
}

