//
//  MainMap.swift
//  MatJang_iOS
//
//  Created by HaeSik Jang on 8/6/24.
//

import Foundation
import UIKit
import KakaoMapsSDK
import Then
import Alamofire
import iOSDropDown
import SafeAreaBrush

enum MapType: String{
    case lookAround, findMatjip
    
    var kind: String{
        switch self{
        case .findMatjip:
            return "findMatjip"
        case .lookAround:
            return "lookAround"
        }
    }
}

protocol getSelectedMatjip: AnyObject {
    func sendData(place_name: String, x: String, y: String)
}

class MainMapViewController: UIViewController, MapControllerDelegate, getSelectedMatjip{
    
    var maptype: MapType = .findMatjip
    
    var findMapPoint: [MapPoint] = []
    
    private var sideMenuVC = SideMenuVC()
    private var dimmingView: UIView?
    var emailTest: String?
    var socialType: SocialType?
    var searchMatjipList: [Matjip] = []
    var categoryMatjipList: [Matjip] = []
    var selectedMatjip: [String:String] = [:]
    
    
    private lazy var sideMenuButton = UIImageView().then{
        $0.image = UIImage(systemName: "text.justify")
        $0.tintColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(presentSideMenu))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var zoomDownButton = UIButton().then{
        $0.backgroundColor = .lightGray
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitle("-", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomOut))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }
    
    private lazy var zoomInButton = UIButton().then{
        $0.backgroundColor = .lightGray
        $0.titleLabel?.font = .systemFont(ofSize: 15)
        $0.setTitle("+", for: .normal)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomIn))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
    }

    
    private lazy var searchButton = UIImageView().then{
        $0.image = UIImage(systemName: "magnifyingglass")
        $0.tintColor = .black
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(searchMatJipFromAPI))
        $0.addGestureRecognizer(tap)
        $0.isUserInteractionEnabled = true
        
    }
    
    private lazy var searchField = UITextField().then{
        $0.placeholder = "검색어를 입력하세요"
        $0.rightView = searchButton
        $0.spellCheckingType = .no
        $0.borderStyle = .line
    }
    
    private lazy var dropDown = DropDown(frame: CGRect(x: 100, y: 100, width: 200, height: 30)).then{
        $0.optionArray = [MapType.findMatjip.kind, MapType.lookAround.kind]
        $0.text = $0.optionArray[0]
        $0.backgroundColor = .lightGray
        $0.selectedIndex = 0
        $0.didSelect{(select, index, id) in
            print("select: \(select)")
            if(select == MapType.lookAround.kind){
                let view = self.mapController?.getView("mapview") as! KakaoMap
                let manager = view.getLabelManager()
                let layer = manager.getLabelLayer(layerID: "PoiLayer")
                layer?.clearAllItems()
            }
        }
    }
    
    @objc func zoomOut(){
        let view = mapController?.getView("mapview") as! KakaoMap
        let position = view.getPosition(CGPoint(x: 1, y: 1))
        let curZoomLevel = view.zoomLevel
        let cameraUpdate = CameraUpdate.make(cameraPosition: CameraPosition(target: position, zoomLevel: curZoomLevel-1, rotation: 0, tilt: 0))
        view.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 500))
    }
    
    @objc func zoomIn(){
        let view = mapController?.getView("mapview") as! KakaoMap
        let position = view.getPosition(CGPoint(x: 1, y: 1))
        let curZoomLevel = view.zoomLevel
        let cameraUpdate = CameraUpdate.make(cameraPosition: CameraPosition(target: position, zoomLevel: curZoomLevel+1, rotation: 0, tilt: 0))
        view.animateCamera(cameraUpdate: cameraUpdate, options: CameraAnimationOptions(autoElevation: false, consecutive: true, durationInMillis: 500))
    }
    
    func sendData(place_name: String, x: String, y: String) {
        self.selectedMatjip["place_name"] = place_name
        self.selectedMatjip["x"] = x
        self.selectedMatjip["y"] = y
    }

    
    required init?(coder aDecoder: NSCoder) {
        _observerAdded = false
        _auth = false
        _appear = false
        let signInVC = SignInView()
//        signInVC.delegate = self
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
//        self.navigationItem.hidesBackButton = true
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.backgroundColor = .lightGray
        self.navigationItem.title = "맛 짱"
//        self.navigationController?.navigationBar.backgroundColor = .white
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: sideMenuButton)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: dropDown)
        
        addDimmingView()
        
        fillSafeArea(position: .top, color: .lightGray)
        
        
        view.addSubview(searchField)
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        searchField.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        
        view.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.leftAnchor.constraint(equalTo: searchField.rightAnchor, constant: 30).isActive = true
        searchButton.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70).isActive = true
        
        view.addSubview(zoomInButton)
        zoomInButton.translatesAutoresizingMaskIntoConstraints = false
        zoomInButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        zoomInButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        
        view.addSubview(zoomDownButton)
        zoomDownButton.translatesAutoresizingMaskIntoConstraints = false
        zoomDownButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        zoomDownButton.topAnchor.constraint(equalTo: zoomInButton.bottomAnchor, constant: 5).isActive = true
        
        
        
//        let tap = SearchBtnGesture(target: self, action: #selector(searchMatjipList))
////        tap.x =
//        searchButton.addGestureRecognizer(tap)
//        searchButton.isUserInteractionEnabled = true

        
        //KMController 생성.
        mapController = KMController(viewContainer: mapContainer!)
        mapController!.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didDismissSearchResultView(_:)), name: NSNotification.Name("DismissSearchResultView"), object: nil)
        
    }
    
    func createLabelLayer() {
        let view = mapController?.getView("mapview") as! KakaoMap
        
        let manager = view.getLabelManager()    //LabelManager를 가져온다. LabelLayer는 LabelManger를 통해 추가할 수 있다.
        
        // 추가할 레이어의 옵션을 지정한다. 옵션에는 레이어에 속할 Label(POI)들의 경쟁방식, 레이어의 zOrder등의 속성을 지정할 수 있다.
        // 경쟁의 의미는 라벨이 표출되어야 하는 영역을 두고 다른 라벨과 경쟁을 함을 의미하고, 경쟁이 발생하게 되면 경쟁에서 이긴 라벨만 그려지게 된다.
        // competitionType : 경쟁의 대상을 지정한다.
        //                   예를 들어, none 으로 지정하게 되면 아무런 라벨과도 경쟁하지 않고 항상 그려지게 된다.
        //                   Upper가 있는 경우, 자신의 상위 레이어의 라벨과 경쟁이 발생한다. Lower가 있는 경우, 자신의 하위 레이어의 라벨과 경쟁한다. Same이 있는 경우, 자신과 같은 레이어에 속한 라벨과도 경쟁한다.
        //                   경쟁은 레이어의 zOrder순(오름차순)으로 진행되며, 레이어에 속한 라벨의 rank순(오름차순)으로 배치 및 경쟁을 진행한다.
        //                   경쟁은 레이어 내의 라벨(자신의 competitionType에 Same이 있는 경우)과 competitionType에 Lower가 있는 경우 자신의 하위 레이어(cocompetitionType에 Upper가 있는 레이어)를 대상으로 진행된다.
        //                   경쟁이 발생하면, 상위 레이어에 속한 라벨이 하위 레이어에 속한 라벨을 이기게 되고, 같은 레이어에 속한 라벨인 경우 rank값이 큰 라벨이 이기게 된다.
        // competitionUnit : 경쟁을 할 때의 영역을 처리하는 단위를 지정한다. .poi의 경우 심볼 및 텍스트 영역 모두가 경쟁영역이 되고, symbolFirst 인 경우 symbol 영역으로 경쟁을 처리하고 텍스트는 그려질 수 있는 경우에 한해 그려진다.
        // zOrder : 레이어의 우선 순위를 결정하는 order 값. 값이 클수록 우선순위가 높다.
        let layerOption = LabelLayerOptions(layerID: "PoiLayer", competitionType: .none, competitionUnit: .poi, orderType: .rank, zOrder: 10001)
        let _ = manager.addLabelLayer(option: layerOption)
    }
    
    func createPoiStyle() {
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        // 심볼을 지정.
        // 심볼의 anchor point(심볼이 배치될때의 위치 기준점)를 지정. 심볼의 좌상단을 기준으로 한 % 값.
        let iconStyle = PoiIconStyle(symbol: UIImage(named: "marker.png"), anchorPoint: CGPoint(x: 0.0, y: 0.5))
        let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)  // 이 스타일이 적용되기 시작할 레벨.
        let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
        manager.addPoiStyle(poiStyle)
    }
    
    // POI를 생성한다.
    func createPoi(x: String, y: String) {
        let view = mapController?.getView("mapview") as! KakaoMap
        
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let poiOption = PoiOptions(styleID: "customStyle1") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
        poiOption.rank = 0
        poiOption.clickable = true // clickable 옵션을 true로 설정한다. default는 false로 설정되어있다.
        
        let poi1 = layer?.addPoi(option: poiOption, at: MapPoint(longitude: Double(x) ?? 0, latitude: Double(y) ?? 0), callback: {(_ poi: (Poi?)) -> Void in
            print("create poi")
        }
        )   //레이어에 지정한 옵션 및 위치로 POI를 추가한다.
        let _ = poi1?.addPoiTappedEventHandler(target: self, handler: MainMapViewController.poiTappedHandler) // poi tap event handler를 추가한다.
        poi1?.show()
    }
    
    // 맛집찾기 드래그시 여러개의 Poi 생성
    func createPois(matjipList: [Matjip])async{
        let view = mapController?.getView("mapview") as! KakaoMap
        let manager = view.getLabelManager()
        let layer = manager.getLabelLayer(layerID: "PoiLayer")   // 생성한 POI를 추가할 레이어를 가져온다.
        let poiOption = PoiOptions(styleID: "customStyle1") // 생성할 POI의 Option을 지정하기 위한 자료를 담는 클래스를 생성. 사용할 스타일의 ID를 지정한다.
        poiOption.rank = 0
        poiOption.clickable = true // clickable 옵션을 true로 설정한다. default는 false로 설정되어있다.
        layer?.clearAllItems()
        self.findMapPoint = []

        var pois: [Poi] = []
        var count = 0
        Task{
            for matjip in matjipList{
                pois.append((layer?.addPoi(option: poiOption, at: MapPoint(longitude: Double(matjip.x ?? "") ?? 0 , latitude: Double(matjip.y ?? "") ?? 0)))!)
                pois[count].addPoiTappedEventHandler(target: self, handler: MainMapViewController.poisTappedHandler)
                pois[count].userObject = [matjip.x, matjip.y] as AnyObject
                pois[count].show()
                count += 1
            }
        }

    }
    
    func onCameraStopped(_ param: CameraActionEventParam){
        
        
        if(dropDown.selectedIndex == 0){
            let mapView = mapController?.getView("mapview") as! KakaoMap
            let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))

            
            Task{
                do{
                    self.categoryMatjipList = try await getMatJipFromAPI(x: String(position.wgsCoord.longitude), y: String(position.wgsCoord.latitude))
                    
                }catch{
                    print("error")
                }
                await createPois(matjipList: self.categoryMatjipList)

            }
            
        }
    }
    
    // POI 탭 이벤트가 발생하고, 표시하고 있던 Poi를 숨긴다.
    func poiTappedHandler(_ param: PoiInteractionEventParam) {
        
    }
    
    func poisTappedHandler(_ param: PoiInteractionEventParam) {
        
        let vc = MatjipInfoBottomSheetView()
        

        let position = param.poiItem.userObject as! [String]
        for matjip in self.categoryMatjipList{
            if(matjip.x == position[0] && matjip.y == position[1]){
                vc.matjip = matjip
                vc.modalPresentationStyle = .pageSheet
                let multiplier = 0.2
                let fraction = UISheetPresentationController.Detent.custom { context in
                    // height is the view.frame.height of the view controller which presents this bottom sheet
                    self.view.frame.height * multiplier
                }
                if let sheet = vc.sheetPresentationController{
                    sheet.detents = [fraction]
                }
                self.present(vc, animated: true)
            }
        }
        
        
    }
    
    @objc func didDismissSearchResultView(_ notification: Notification){
        moveCameraAfterSearch(x: self.selectedMatjip["x"] ?? "", y: self.selectedMatjip["y"] ?? "")
    }
    
    func moveCameraAfterSearch(x: String, y: String) {
        let mapView: KakaoMap = mapController?.getView("mapview") as! KakaoMap
        
        // CameraUpdateType을 CameraPosition으로 생성하여 지도의 카메라를 특정 좌표로 이동시킨다. MapPoint, 카메라가 바라보는 높이, 회전각 및 틸트를 지정할 수 있다.
        mapView.moveCamera(CameraUpdate.make(cameraPosition: CameraPosition(target: MapPoint(longitude: Double(x) ?? 0, latitude: Double(y) ?? 0), height: 0, rotation: 0, tilt: 0)))
        
        createPoi(x: x, y: y)
        
    }
    
    func getMatJipFromAPI(x: String, y: String) async throws -> [Matjip]{
        
        self.categoryMatjipList = []
        
        
        let url = "https://dapi.kakao.com/v2/local/search/category.json"
        let parameters = ["category_group_code": "FD6", "x": x, "y": y, "radius": "1000"]
        let headers: HTTPHeaders = ["Authorization": "KakaoAK \(Bundle.main.infoDictionary?["KAKAO_REST_API_KEY"] as? String ?? "")"]
        
        
        let dataTask = AF.request(url, method: .get, parameters: parameters, headers: headers).serializingDecodable(MatjipList.self)
        
        switch await dataTask.result {
        case .success(let data):
            
            return data.documents
        case .failure(let error):
            print(error)
            throw error
        }
    
    }
    
//    func getMatJipFromAPI(x: String, y: String) async{
//        
//        self.categoryMatjipList = []
//                
//        let url = "https://dapi.kakao.com/v2/local/search/category.json"
//        let parameters = ["category_group_code": "FD6", "x": x, "y": y, "radius": "1000"]
//        let headers: HTTPHeaders = ["Authorization": "KakaoAK \(Bundle.main.infoDictionary?["KAKAO_REST_API_KEY"] as? String ?? "")"]
//        Task{
//            AF.request(url, method: .get, parameters: parameters, headers: headers)
//                .validate(statusCode: 200..<500)
//                .responseJSON{response in
//                    switch response.result{
//                    case .success(let data):
//                        do {
//                            let value = [data]
//                            for val in value{
//                                if let obj = val as? [String: Any]{
//                                    if let convData = obj["documents"] as? [[String:String]]{
//                                        for temp in convData{
//                                            self.categoryMatjipList.append(Matjip(place_name: temp["place_name"], x: temp["x"], y: temp["y"], address_name: temp["road_address_name"], category_name: temp["category_name"]))
//                                        }
//                                    }
//                                    
//                                }
//                            }
//                        }
//                        break
//                    case .failure(let error):
//                        print(error)
//                        break
//
//                    }
//                }
//        }
//        
//        
//    }
    
    @objc func searchMatJipFromAPI(){
        
        let mapView = mapController?.getView("mapview") as! KakaoMap
        let position = mapView.getPosition(CGPoint(x: 0.5, y: 0.5))
        
        self.searchMatjipList = []
                
        if searchField.text != "" {
            let query = searchField.text
            let url = "https://dapi.kakao.com/v2/local/search/keyword.json"
            let parameters = ["query": query, "category_group_code": "FD6", "x": String(position.wgsCoord.latitude), "y": String( position.wgsCoord.longitude), "radius": "1000"]
            let headers: HTTPHeaders = ["Authorization": "KakaoAK \(Bundle.main.infoDictionary?["KAKAO_REST_API_KEY"] as? String ?? "")"]
            AF.request(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!, method: .get, parameters: parameters, headers: headers)
                .validate(statusCode: 200..<500)
                .responseJSON{response in
                    switch response.result{
                    case .success(let data):
                        do{
                            let value = [data]
                            for val in value{
                                if let obj = val as? [String: Any]{
                                    if let convData = obj["documents"] as? [[String:String]]{
                                        for temp in convData{
                                            self.searchMatjipList.append(Matjip(place_name: temp["place_name"], x: temp["x"], y: temp["y"], address_name: temp["road_address_name"], category_name: temp["category_name"]))
                                            
                                        }
                                    }
                                    
                                }
                            }
                            
                            let searchVC = SearchResultView()
                            searchVC.delegate = self
                            searchVC.search_list = self.searchMatjipList
                            self.searchField.text = ""
                            self.present(searchVC, animated: false)
                        }
                        break
                    case .failure(let error):
                        print(error)
                        break

                    }
                }
        }
        else{
            let alert = UIAlertController(title: "Error",message: "검색어를 입력해주세요", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive))
            self.present(alert, animated: false)
        }
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
        print("view will appear")
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
        
//        let mapView = mapController?.getView("mapview") as! KakaoMap
//        
//        _cameraStoppedHandler = mapView.addCameraStoppedEventHandler(target: self, handler: MainMapViewController.onCameraStopped)


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
        print("didBecomeActive")
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
    
    
    
    
    
    var _cameraStoppedHandler: DisposableEventHandler?
    
    
    var mapContainer: KMViewContainer?
    var mapController: KMController?
    var _observerAdded: Bool
    var _auth: Bool
    var _appear: Bool
}
