//
//  NoticePopupView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct NoticePopupView: View {
    @Binding var showModal: Bool
    var onCompletion: ((String, String) -> Void)?
    var onSetupTapped: (() -> Void)?

    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 5)
            Text("소속 대학과 수강 학기를 설정해 주셔야 \n시간표를 제공해 드릴 수 있어요!")
                .font(.pretendSemiBold16)
                .multilineTextAlignment(.center)
            
            Button(action: {
                onSetupTapped?()
                showModal = false
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
        showModal: .constant(true),
        onCompletion: { school, semester in
            print("선택된 학교: \(school), 학기: \(semester)")
        },
        onSetupTapped: {
            print("학교/학기 설정 버튼이 탭되었습니다.")
        }
    )
}
