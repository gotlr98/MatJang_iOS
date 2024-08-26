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
    let appleButton = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
    
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
                    
                    guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MainMapVC") else {return}
                    self.present(nextVC, animated: false, completion: nil)
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
//                        let mainVC = MainMap(nibName: nil, bundle: nil)
//                        mainVC.modalPresentationStyle = .fullScreen
//                        self.present(mainVC, animated: false)
                        
                        guard let nextVC = self.storyboard?.instantiateViewController(identifier: "MainMapVC") else {return}
                        self.present(nextVC, animated: false, completion: nil)
                    }
                }
        }
    }
    
    override func viewDidLoad(){
        
        self.view.addSubview(kakaoButton)
        self.view.addSubview(appleButton)
        
        kakaoButton.translatesAutoresizingMaskIntoConstraints = false
        kakaoButton.addTarget(self, action: #selector(onPressKakaoButton), for: .touchUpInside)
        kakaoButton.setTitle("카카오 로그인", for: .normal)
        kakaoButton.setImage(UIImage(named: "kakao_login_medium_narrow"), for: .normal)
        
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
//                    let mainVC = MainMap(nibName: nil, bundle: nil)
//                    mainVC.modalPresentationStyle = .fullScreen
//                    self.present(mainVC, animated: false)
                    return
 
                case let passwordCredential as ASPasswordCredential:
                    // Sign in using an existing iCloud Keychain credential.
                    let username = passwordCredential.user
                    let password = passwordCredential.password
                    
                    print("username: \(username)")
                    print("password: \(password)")
                    
//                    let mainVC = MainMap(nibName: nil, bundle: nil)
//                    mainVC.modalPresentationStyle = .fullScreen
//                    self.present(mainVC, animated: false)
                    return
                
                default:
                    break
                }
        }
        

        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // 로그인 실패(유저의 취소도 포함)
            print("login failed - \(error.localizedDescription)")
        }
}
