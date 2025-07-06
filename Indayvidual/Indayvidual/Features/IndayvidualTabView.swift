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
    
    // MARK: - Body
    var body: some View{
        NavigationStack{
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
    }
    
    private func tabLabel(_ tab: TabCase) -> some View{
        VStack(spacing: 4, content: {
            tab.icon
                .renderingMode(.template)
            
            //폰트 합친 이후 수정 예정
            Text(tab.rawValue)
                .font(.caption)
                .foregroundStyle(Color.gray)
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
    IndayvidualTabView(tabcase: .home)
}
