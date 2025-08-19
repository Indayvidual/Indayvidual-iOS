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
    let showSettingsButton: Bool
    
    init(customAction: (() -> Void)? = nil, showSettingsButton: Bool = true) {
        self.customAction = customAction
        self.showSettingsButton = showSettingsButton
    }
    
    var body : some View{
        HStack{
            Image(.indayvidual)
            
            Spacer()
            
            if showSettingsButton {   // true일 때만 버튼 노출
                Button(action: {
                    if let customAction = customAction {
                        customAction()
                    } else {
                        navigateToSettings()
                    }
                }) {
                    Image(.gear)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .scaledToFit()
                }
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
