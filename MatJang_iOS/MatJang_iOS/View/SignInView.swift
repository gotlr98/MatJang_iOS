//
//  SignInView.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 7/29/24.
//

import UIKit
import KakaoSDKAuth
import KakaoSDKUser
import AuthenticationServices
import JWTDecode

class SignInView: UIViewController{
    
    let kakaoButton = UIButton()
    let appleButton = UIButton()
//    let kakaoLabel = UILabel()
    
    @objc func onPressKakaoButton(_sender: UIButton){
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                }
                else {
                    print("loginWithKakaoTalk() success.")

                    //do something
                    _ = oauthToken
                }
            }
        }
        else{
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        print("loginWithKakaoAccount() success.")

                        //do something
                        _ = oauthToken
                    }
                }
        }
    }
    
    override func viewDidLoad(){
        
        self.view.addSubview(kakaoButton)
        self.view.addSubview(appleButton)
        
        kakaoButton.translatesAutoresizingMaskIntoConstraints = false
        kakaoButton.addTarget(self, action: #selector(onPressKakaoButton), for: .touchUpInside)
        kakaoButton.setTitle("카카오 로그인", for: <#T##UIControl.State#>)
        
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(onPressAppleButton), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            kakaoButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            kakaoButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 10),
            kakaoButton.heightAnchor.constraint(equalToConstant: 50),
            kakaoButton.widthAnchor.constraint(equalToConstant: 200),
            appleButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            appleButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 60),
            appleButton.heightAnchor.constraint(equalToConstant: 50),
            appleButton.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        
    }
}

extension SignInView: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    @objc func onPressAppleButton(_sender: UIButton){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
         let request = appleIDProvider.createRequest()
         request.requestedScopes = [.fullName, .email] //유저로 부터 알 수 있는 정보들(name, email)
                
         let authorizationController = ASAuthorizationController(authorizationRequests: [request])
         authorizationController.delegate = self
         authorizationController.presentationContextProvider = self
         authorizationController.performRequests()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
            return self.view.window!
        }

        func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        //로그인 성공
            switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                // You can create an account in your system.
                let userIdentifier = appleIDCredential.user
                let fullName = appleIDCredential.fullName
                let email = appleIDCredential.email
                
                if  let authorizationCode = appleIDCredential.authorizationCode,
                    let identityToken = appleIDCredential.identityToken,
                    let identityTokenString = String(data: identityToken, encoding: .utf8) {
                    print("Identity Token \(identityTokenString)")
                    do {
                        let jwt = try decode(jwt: identityTokenString)
                        let decodedBody = jwt.body as Dictionary<String, Any>
                        print(decodedBody)
                        print("Decoded email: "+(decodedBody["email"] as? String ?? "n/a")   )
                    } catch {
                        print("decoding failed")
                    }
                }
                
                print("useridentifier: \(userIdentifier)")
                print("fullName: \(fullName)")
                print("email: \(email)")
                
                //Move to MainPage
                //let validVC = SignValidViewController()
                //validVC.modalPresentationStyle = .fullScreen
                //present(validVC, animated: true, completion: nil)
                
            case let passwordCredential as ASPasswordCredential:
                // Sign in using an existing iCloud Keychain credential.
                let username = passwordCredential.user
                let password = passwordCredential.password
                
                print("username: \(username)")
                print("password: \(password)")
                
            default:
                break
            }
        }
        

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // 로그인 실패(유저의 취소도 포함)
            print("login failed - \(error.localizedDescription)")
        }
}
