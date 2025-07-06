//
//  Topbar.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import SwiftUI

// MARK: 모든 탭 위에 들어갈 Topbar입니다. 사용 시 NavigationStack안에 넣어주세요!
struct Topbar: View{
    var body : some View{
        HStack{
            Image(.indayvidual)
            
            Spacer()
            
            //추후 SettingsView로 연결 예정
            NavigationLink(destination: Color.black){
                Image(.settings1)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    Topbar()
}
