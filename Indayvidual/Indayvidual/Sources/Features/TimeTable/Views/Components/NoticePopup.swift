//
//  NoticePopupView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct NoticePopupView: View {
    var onSetupTapped: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 5)
            Text("소속 대학과 수강 학기를 설정해 주셔야 \n시간표를 제공해 드릴 수 있어요!")
                .font(.pretendSemiBold16)
                .multilineTextAlignment(.center)
            
            Button(action: {
                onSetupTapped()
            }) {
                Text("학교/학기 설정하러 가기")
                    .font(.pretendSemiBold14)
                    .foregroundColor(.white)
                    .padding()
                    .frame(height: 48)
                    .frame(maxWidth: .infinity)
                    .background(Color(.gray900))
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    NoticePopupView(
    ) {
        print("학교/학기 설정 버튼이 탭되었습니다.")
    }
}
