//
//  KakaoMapView.swift
//  MatJang
//
//  Created by HaeSik Jang on 7/23/24.
//

import Foundation

import KakaoMapsSDK
import SwiftUI

struct KakaoMapView: UIViewRepresentable{
    
    @Binding var draw: Bool
    
    func makeUIView(context: Self.Context) -> KMViewContainer {
        //need to correct view size
        let view: KMViewContainer = KMViewContainer(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))

        context.coordinator.createController(view)
        
        return view
    }

    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        if draw {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if context.coordinator.controller?.isEnginePrepared == false {
                    context.coordinator.controller?.prepareEngine()
                }
                
                if context.coordinator.controller?.isEngineActive == false {
                    context.coordinator.controller?.activateEngine()
                }
            }
        }
        else {
            context.coordinator.controller?.pauseEngine()
            context.coordinator.controller?.resetEngine()
        }
    }
    
    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator()
    }

    /// Cleans up the presented `UIView` (and coordinator) in
    /// anticipation of their removal.
    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        
    }
    
    class KakaoMapCoordinator: NSObject, MapControllerDelegate{
        override init() {
            first = true
            auth = false
            _observerAdded = false
            let mapView = controller?.getView("mapview") as! KakaoMap
            _mapTapEventHandler = mapView.addMapTappedEventHandler(target: self, handler: TappedEventHandler.mapDidTapped)
            _terrainTapEventHandler = mapView.addTerrainTappedEventHandler(target: self, handler: TappedEventHandler.terrainTapped)
            _terrainLongTapEventHandler = mapView.addTerrainLongPressedEventHandler(target: self, handler: TappedEventHandler.terrainLongTapped)
            super.init()
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
            controller?.pauseEngine()  //뷰가 inactive 상태로 전환되는 경우 렌더링 중인 경우 렌더링을 중단.
        }

        @objc func didBecomeActive(){
            controller?.activateEngine() //뷰가 active 상태가 되면 렌더링 시작. 엔진은 미리 시작된 상태여야 함.
        }
        
        func createController(_ view: KMViewContainer) {
            container = view
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }
        
        func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: 126.978365, latitude: 37.566691)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
            
            controller?.addView(mapviewInfo)
        }
        
        func addViewSucceeded(_ viewName: String, viewInfoName: String) {
            print("OK")
            let view = controller?.getView("mapview")
            view?.viewRect = container!.bounds
        }
        
        func containerDidResized(_ size: CGSize) {
            let mapView: KakaoMap? = controller?.getView("mapview") as? KakaoMap
            mapView?.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            if first {
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: 126.978365, latitude: 37.566691), mapView: mapView!)
                mapView?.moveCamera(cameraUpdate)
                first = false
            }
        }
        
        func authenticationSucceeded() {
            auth = true
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
        
        var controller: KMController?
        var container: KMViewContainer?
        var first: Bool
        var auth: Bool
        var _observerAdded: Bool
        var _mapTapEventHandler: DisposableEventHandler?
        var _terrainTapEventHandler: DisposableEventHandler?
        var _terrainLongTapEventHandler: DisposableEventHandler?

    }
    
    
    
    
    
    
    
    
    class APISampleBaseViewController: UIViewController, MapControllerDelegate {
        
        required init?(coder aDecoder: NSCoder) {
            _observerAdded = false
            _auth = false
            _appear = false
            super.init(coder: aDecoder)
        }
        
        deinit {
            mapController?.pauseEngine()
            mapController?.resetEngine()
            
            print("deinit")
        }
        
        override func viewDidLoad() {
            
            super.viewDidLoad()
            mapContainer = self.view as? KMViewContainer
            
            //KMController 생성.
            mapController = KMController(viewContainer: mapContainer!)
            mapController!.delegate = self
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
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
            
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
        
        var mapContainer: KMViewContainer?
        var mapController: KMController?
        var _observerAdded: Bool
        var _auth: Bool
        var _appear: Bool
    }
    
    class TappedEventHandler: APISampleBaseViewController {
        
        override func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: 127.02768, latitude: 37.498254)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition)
            
            mapController?.addView(mapviewInfo)
        }
        
        override func viewInit(viewName: String) {
            print("OK")
            
            // 카메라 이동 멈춤 핸들러를 추가한다.
            let mapView = mapController?.getView("mapview") as! KakaoMap
            _mapTapEventHandler = mapView.addMapTappedEventHandler(target: self, handler: TappedEventHandler.mapDidTapped)
            _terrainTapEventHandler = mapView.addTerrainTappedEventHandler(target: self, handler: TappedEventHandler.terrainTapped)
            _terrainLongTapEventHandler = mapView.addTerrainLongPressedEventHandler(target: self, handler: TappedEventHandler.terrainLongTapped)
        }
        
        func mapDidTapped(_ param: ViewInteractionEventParam) {
            let mapView = param.view as! KakaoMap
            let position = mapView.getPosition(param.point)
            
            print("Tapped: \(position.wgsCoord.latitude), \(position.wgsCoord.latitude)")
            
            _mapTapEventHandler?.dispose()
        }
        
        func terrainTapped(_ param: TerrainInteractionEventParam) {
            let position = param.position.wgsCoord
            print("Terrain Tapped: \(position.longitude), \(position.latitude)")
            
            _terrainTapEventHandler?.dispose()
        }
        
        func terrainLongTapped(_ param: TerrainInteractionEventParam) {
            let position = param.position.wgsCoord
            print("Terrain Long Tapped: \(position.longitude), \(position.latitude)")
            
            _terrainLongTapEventHandler?.dispose()
        }
        
        var _mapTapEventHandler: DisposableEventHandler?
        var _terrainTapEventHandler: DisposableEventHandler?
        var _terrainLongTapEventHandler: DisposableEventHandler?
    }
}

