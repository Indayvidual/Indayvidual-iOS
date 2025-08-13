//
//  EmptyScheduleView.swift
//  Indayvidual
//
//  Created by 장주리 on 8/13/25.
//

import SwiftUI

struct EmptyScheduleView: View {
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(.todoCheckbox)
                .resizable()
                .scaledToFit()
                .frame(width: 62, height: 62)
            
            Spacer().frame(height: 10)
            
            Text("등록된 일정이 없습니다." )
                .foregroundColor(Color(.gray500))
                .font(.pretendMedium14)
                        
            Text("하단 + 버튼을 클릭하여 일정을 생성하세요." )
                .foregroundColor(Color(.gray500))
                .font(.system(size: 12))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmptyScheduleView()
}
