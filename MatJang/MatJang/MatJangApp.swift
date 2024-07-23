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
    let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? ""

    init(){
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
    }
    var body: some Scene {
        
        
        WindowGroup {
            LoginView()
        }
    }
}
