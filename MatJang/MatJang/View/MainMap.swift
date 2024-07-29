//
//  MainMap.swift
//  MatJang
//
//  Created by HaeSik Jang on 7/16/24.
//

import SwiftUI

struct MainMap: View {
    
    @State var draw: Bool = false
    
    var body: some View {
        
        ZStack(alignment: .bottom){
            KakaoMapView(draw: $draw).onAppear(perform: {
                self.draw = true
            }).onDisappear(perform: {
                self.draw = false
            }).frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}

//#Preview {
//    MainMap()
//}
