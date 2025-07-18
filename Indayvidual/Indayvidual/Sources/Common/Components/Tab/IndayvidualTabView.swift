//
//  IndayvidualTabView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/6/25.
//

import SwiftUI

struct IndayvidualTabView: View{
    //기본 선택된 탭
    @State var tabcase: TabCase = .home

    init() {
        if let customFont = UIFont(name: "Pretendard-Regular", size: 12) {
            UITabBarItem.appearance().setTitleTextAttributes([.font: customFont], for: .normal)
            UITabBarItem.appearance().setTitleTextAttributes([.font: customFont], for: .selected)
        }
        UITabBar.appearance().tintColor = .black              // 선택된 아이콘·텍스트 색
        UITabBar.appearance().unselectedItemTintColor = .gray // 선택 안 된 텍스트 색
        
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    
    // MARK: - Body
    var body: some View{
        TabView(selection: $tabcase, content: {
            ForEach(TabCase.allCases, id: \.rawValue){ tab in
                Tab(
                    value: tab,
                    content: {
                        tabView(tab: tab)
                            .tag(tab)
                    },
                    label: {
                        tabLabel(tab)
                    })
            }
        })
        .tint(.black)
    }
    
    private func tabLabel(_ tab: TabCase) -> some View{
        VStack(spacing: 4, content: {
            tab.icon
                .renderingMode(.template)
            
            Text(tab.rawValue)
        })
    }
    
    // MARK: - 각 탭에 해당하는 tabView 각 뷰 파일 생성 이후 Color부분 지우고 View 넣어주세요!
    @ViewBuilder
    private func tabView(tab: TabCase) -> some View {
        Group{
            switch tab {
            case .home :
                Color.white
            case .todo :
                Color.black
            case .timetable :
                Color.blue
            case .custom :
                CustomView()
            case .settings :
                Color.gray
            }
        }
    }
}

#Preview{
    IndayvidualTabView()
}
