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
import AuthenticationServices
import JWTDecode

struct LoginView: View{
    
    @State var isAppleSignIn: Bool = false
    @State var isKakaoSignIn: Bool = false
    var body: some View{
        NavigationView {
            VStack {
                NavigationLink(destination: MainMap(), isActive: $isKakaoSignIn, label:{
                    Button {
                        if (UserApi.isKakaoTalkLoginAvailable()) {
                        UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                            if let error = error{
                                print(error)
                            }
                            else{
                                isKakaoSignIn = true
                            }
                        }
                    } else {
                            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                                if let error = error{
                                    print(error)
                                }
                                else{
                                    isKakaoSignIn = true
                                }
                            }
                        }
                    } label : {
                        Image("kakao_login_medium_narrow")
                            .resizable()
                            .frame(width : UIScreen.main.bounds.width * 0.9, height:50)
                }
                
                })
                NavigationLink(destination: MainMap(), isActive: $isAppleSignIn){
                    SignInWithAppleButton(onRequest: {request in
                        request.requestedScopes = [.fullName, .email]
                    }, onCompletion: {result in
                        switch result{
                        case .success(let authResults):
                            print("Sucess")
                            switch authResults.credential{
                            case let appleIdCredential as ASAuthorizationAppleIDCredential:
                                let UserIdentifier = appleIdCredential.user
                                let fullName = appleIdCredential.fullName
                                let name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                                let email = appleIdCredential.email ?? ""
                                let IdentityToken = String(data: appleIdCredential.identityToken!, encoding: .utf8)
                                let AuthorizationCode = String(data: appleIdCredential.authorizationCode!, encoding: .utf8)
                                
                                
                                if(email == ""){
                                    if let identityTokenData = appleIdCredential.identityToken,
                                       let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                                        do {
                                            let jwt = try decode(jwt: identityTokenString)
                                            let decodedBody = jwt.body as Dictionary<String, Any>
                                            print("Decoded email: "+(decodedBody["email"] as? String ?? "n/a")   )
                                            isAppleSignIn = true
                                        } catch {
                                            print("decoding failed")
                                        }}
                                }
                                else{
                                    print("email:" + email)
                                    isAppleSignIn = true
                                }
                                
                                
                                
                            default:
                                break
                            }
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    })
                    .frame(width : UIScreen.main.bounds.width * 0.9, height:50)
                    .cornerRadius(5)
                }
                
                
            }
            .padding()
        }
    }
}

//struct SignInWithApple: View{
//    @State var isActive: Bool = false
//    var body: some View{
//        
//    }
//}

#Preview{
    LoginView()
}
