//
//  LoginView.swift
//  MatJang
//
//  Created by HaeSik Jang on 7/15/24.
//

import Foundation
import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser

struct LoginView: View{
    var body: some View{
        VStack {
            Button {
                if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                        print(oauthToken)
                        print(error)
                    }
                } else {
                    UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                        print(oauthToken)
                    print(error)
                    }
                }
            } label : {
                Image("kakao_login_medium_narrow")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width : UIScreen.main.bounds.width * 0.9)
            }
        }
        .padding()
    }
}

#Preview{
    LoginView()
}
