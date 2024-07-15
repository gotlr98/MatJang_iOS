//
//  MatJangApp.swift
//  MatJang
//
//  Created by HaeSik Jang on 7/15/24.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct MatJangApp: App {
    init(){
        KakaoSDK.initSDK(appKey: ${KAKAO_NATIVE_APP_KEY})
    }
    var body: some Scene {
        
        
        WindowGroup {
            ContentView()
        }
    }
}
