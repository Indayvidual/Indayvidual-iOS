//
//  EmptyTimeTableView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/24/25.
//

import SwiftUI

struct EmptyTimeTableView: View {
    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Image(.reservationFill)
                .resizable()
                .scaledToFit()
                .frame(width: 62, height: 62)
            
            Spacer().frame(height: 10)
            
            Text("아직 등록된 시간표가 없습니다." )
                .foregroundColor(Color(.gray500))
                .font(.pretendMedium14)
                        
            Text("소속 대학교와 시간표를 추가해 주세요." )
                .foregroundColor(Color(.gray500))
                .font(.system(size: 12))
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
    }
}

#Preview {
    EmptyTimeTableView()
}
