//
//  MainMap.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 8/6/24.
//

import Foundation
import UIKit
import KakaoMapsSDK
import SideMenu
import Then

class MainMapViewController: UIViewController, MapControllerDelegate{
    
    private var sideMenuVC = SideMenuVC()
    private var dimmingView: UIView?
    var emailTest: String?
    var socialType: SocialType?
    
    private lazy var sideMenuButton = UIImageView().then{
        $0.image = UIImage(systemName: "text.justify")
        $0.tintColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentSideMenu))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var testButton = UIImageView().then{
        $0.image = UIImage(systemName: "figure.run")
        $0.tintColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(getMatJipFromAPI))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
//    func sendUserInfo(user: UserModel) {
//        self.email = user.email
//        self.socialType = user.socialType
//        
//        print(self.email)
//        print("email here")
//        
//    }
    
    required init?(coder aDecoder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        let signInVC = SignInView()
//        signInVC.delegate = self
        super.init(coder: aDecoder)
    }
    
//    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        _observerAdded = false
//        _auth = false
//        _appear = false
//        super.init(nibName: nil, bundle: nil)
//    }


    
    deinit {
        mapController?.pauseEngine()
        mapController?.resetEngine()
        
        print("deinit")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        mapContainer = self.view as? KMViewContainer
//        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationItem.title = "맛 짱"
//        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
        
        addDimmingView()
        
        
        view.addSubview(testButton)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        testButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        testButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40).isActive = true

        
        //KMController 생성.
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
        
        
    }
    
    private func addDimmingView() {
        dimmingView = UIView(frame: self.view.bounds)
        dimmingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView?.isHidden = true
        view.addSubview(dimmingView!)
        
//        view.addSubview(sideMenuButton)
//        
//        sideMenuButton.translatesAutoresizingMaskIntoConstraints = false
//        sideMenuButton.centerXAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
//        sideMenuButton.centerYAnchor.constraint(equalTo: self.view.topAnchor, constant: 60).isActive = true
//        sideMenuButton.
            
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView?.addGestureRecognizer(tapGesture)
        }
    
    @objc private func handleDimmingViewTap() {
            let sideMenuVC = self.sideMenuVC
            
            UIView.animate(withDuration: 0.3, animations: {
                // 사이드 메뉴를 원래 위치로 되돌림.
                sideMenuVC.view.frame = CGRect(x: -self.view.frame.width, y: 0, width: self.view.frame.width, height: self.view.frame.height)
                // 어두운 배경 뷰를 숨김.
                self.dimmingView?.alpha = 0
            }) { (finished) in
                // 애니메이션이 완료된 후 사이드 메뉴를 뷰 계층 구조에서 제거.
                sideMenuVC.view.removeFromSuperview()
                sideMenuVC.removeFromParent()
                self.dimmingView?.isHidden = true
            }
        }
    
    @objc private func presentSideMenu() {
            let sideMenuVC = self.sideMenuVC
            
            // 사이드 메뉴 뷰 컨트롤러를 자식으로 추가하고 뷰 계층 구조에 추가.
            self.addChild(sideMenuVC)
            self.view.addSubview(sideMenuVC.view)
            
            // 사이드 메뉴의 너비를 화면 너비의 80%로 설정.
            let menuWidth = self.view.frame.width * 0.65
            let menuHeight = self.view.frame.height
            let yPos = (self.view.frame.height / 2) - (menuHeight / 2) // 중앙에 위치하도록 yPos 계산

            
            // 사이드 메뉴의 시작 위치를 화면 왼쪽 바깥으로 설정.
            sideMenuVC.view.frame = CGRect(x: -menuWidth, y: yPos, width: menuWidth, height: menuHeight)
            
            // 어두운 배경 뷰를 보이게 합니다.
            self.dimmingView?.isHidden = false
            self.dimmingView?.alpha = 0
            
            UIView.animate(withDuration: 0.3, animations: {
                // 사이드 메뉴를 화면에 표시.
                sideMenuVC.view.frame = CGRect(x: 0, y: yPos, width: menuWidth, height: menuHeight)
                // 어두운 배경 뷰의 투명도를 조절.
                self.dimmingView?.alpha = 0.5
            })
        }

    override func viewWillAppear(_ animated: Bool) {
        addObservers()
        _appear = true
        if mapController?.isEnginePrepared == false {
            mapController?.prepareEngine()
        }
        
        if mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
        
    override func viewWillDisappear(_ animated: Bool) {
        _appear = false
        mapController?.pauseEngine()  //렌더링 중지.
    }

    override func viewDidDisappear(_ animated: Bool) {
        removeObservers()
        mapController?.resetEngine()     //엔진 정지. 추가되었던 ViewBase들이 삭제된다.
    }
    
    // 인증 성공시 delegate 호출.
    func authenticationSucceeded() {
        // 일반적으로 내부적으로 인증과정 진행하여 성공한 경우 별도의 작업은 필요하지 않으나,
        // 네트워크 실패와 같은 이슈로 인증실패하여 인증을 재시도한 경우, 성공한 후 정지된 엔진을 다시 시작할 수 있다.
        if _auth == false {
            _auth = true
        }
        
        if _appear && mapController?.isEngineActive == false {
            mapController?.activateEngine()
        }
    }
    
    // 인증 실패시 호출.
    func authenticationFailed(_ errorCode: Int, desc: String) {
        print("error code: \(errorCode)")
        print("desc: \(desc)")
        _auth = false
        switch errorCode {
        case 400:
            showToast(self.view, message: "지도 종료(API인증 파라미터 오류)")
            break;
        case 401:
            showToast(self.view, message: "지도 종료(API인증 키 오류)")
            break;
        case 403:
            showToast(self.view, message: "지도 종료(API인증 권한 오류)")
            break;
        case 429:
            showToast(self.view, message: "지도 종료(API 사용쿼터 초과)")
            break;
        case 499:
            showToast(self.view, message: "지도 종료(네트워크 오류) 5초 후 재시도..")
            
            // 인증 실패 delegate 호출 이후 5초뒤에 재인증 시도..
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                print("retry auth...")
                
                self.mapController?.prepareEngine()
            }
            break;
        default:
            break;
        }
    }
    
    func addViews() {
        //여기에서 그릴 View(KakaoMap, Roadview)들을 추가한다.
        let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
        //지도(KakaoMap)를 그리기 위한 viewInfo를 생성
        let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 15)
        
        //KakaoMap 추가.
        mapController?.addView(mapviewInfo)
    }
    
    func viewInit(viewName: String) {
        print("OK")

    }
    
    //addView 성공 이벤트 delegate. 추가적으로 수행할 작업을 진행한다.
    func addViewSucceeded(_ viewName: String, viewInfoName: String) {
        let view = mapController?.getView("mapview") as! KakaoMap
        view.viewRect = mapContainer!.bounds    //뷰 add 도중에 resize 이벤트가 발생한 경우 이벤트를 받지 못했을 수 있음. 원하는 뷰 사이즈로 재조정.
        viewInit(viewName: viewName)
    }
    
    //addView 실패 이벤트 delegate. 실패에 대한 오류 처리를 진행한다.
    func addViewFailed(_ viewName: String, viewInfoName: String) {
        print("Failed")
    }
    
    //Container 뷰가 리사이즈 되었을때 호출된다. 변경된 크기에 맞게 ViewBase들의 크기를 조절할 필요가 있는 경우 여기에서 수행한다.
    func containerDidResized(_ size: CGSize) {
        let mapView: KakaoMap? = mapController?.getView("mapview") as? KakaoMap
        mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)   //지도뷰의 크기를 리사이즈된 크기로 지정한다.
    }
       
    func addObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    
        _observerAdded = true
    }
     
    func removeObservers(){
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)

        _observerAdded = false
    }

    @objc func willResignActive(){
        mapController?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
    }

    @objc func didBecomeActive(){
        mapController?.activateEngine() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
    }
    
    func showToast(_ view: UIView, message: String, duration: TimeInterval = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: view.frame.size.width/2 - 150, y: view.frame.size.height-100, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = NSTextAlignment.center;
        view.addSubview(toastLabel)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        UIView.animate(withDuration: 0.4,
                       delay: duration - 0.4,
                       options: UIView.AnimationOptions.curveEaseOut,
                       animations: {
                                        toastLabel.alpha = 0.0
                                    },
                       completion: { (finished) in
                                        toastLabel.removeFromSuperview()
                                    })
    }
    
    @objc func getMatJipFromAPI(){
        
        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/search/category.json?")
                //도메인 뒤에 API 주소 삽입
        //파라미터 추가할거 있으면 작성
        let parameters = [URLQueryItem(name: "category_group_code", value: "FD6"),
                          URLQueryItem(name: "x", value: "127.108678"),
                          URLQueryItem(name: "y", value: "37.402001"),
                          URLQueryItem(name: "radius", value: "10000")]
        components?.percentEncodedQueryItems = parameters
        //URL 생성
        guard let url = components?.url else { return }
        print(url)
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? "", forHTTPHeaderField: "Authorization: KakaoAK")
        
        let task = URLSession.shared.dataTask(with: request){ data, response, error in
            guard error == nil else{
                print("\(error) error calling Get")
                return
            }
            
            guard let data = data else{
                print("did not receive data")
                return
            }
            
            guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else{
                print("HTTP request fail")
                return
            }
            
//            guard let output = try? JSONDecoder().decode(response.self, from: data) else{
//                print("JSON data decode fail")
//                return
//            }
            
            print(response.statusCode)
            
            
        }
        task.resume()
        
    }
    
    
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    var _observerAdded: Bool
    var _auth: Bool
    var _appear: Bool
}
