//
//  Topbar.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import SwiftUI

// MARK: 모든 탭 위에 들어갈 Topbar입니다.
struct Topbar: View{
    let customAction: (() -> Void)?
    
    init(customAction: (() -> Void)? = nil) {
        self.customAction = customAction
    }
    
    var body : some View{
        HStack{
            Image(.indayvidual)
            
            Spacer()
            
            Button(action: {
                if let customAction = customAction {
                    //todolistview에서는 설정버튼이 수정버튼이 되어서 추가했습니다. 
                    customAction()
                } else {
                    navigateToSettings()
                }
            }){
                Image(.gear)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .scaledToFit()
            }
        }
        .padding(.horizontal)
    }
    
    private func navigateToSettings() {
        // 여기에 설정뷰로 이동하는 로직 구현
        print("설정뷰로 이동")
    }
}

#Preview {
    Topbar()
}
