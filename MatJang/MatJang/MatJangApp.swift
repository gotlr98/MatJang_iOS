//
//  MatJangApp.swift
//  MatJang
//
//  Created by HaeSik Jang on 7/15/24.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon
import KakaoMapsSDK
import FirebaseCore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
@main
struct MatJangApp: App {
    let kakaoNativeAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? ""

    init(){
        KakaoSDK.initSDK(appKey: kakaoNativeAppKey)
        SDKInitializer.InitSDK(appKey: kakaoNativeAppKey)
    }
    var body: some Scene {
        @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
        WindowGroup {
            MainMap()

        }
        
    }
    
}


