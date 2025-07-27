//
//  SignupCompleteView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct SignupCompleteView: View {
    var body: some View {
        VStack(spacing: 34) {
            Spacer()

            // 이미지
            Image("Indayvidual")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)

            VStack (spacing: 8){
                // 타이틀
                Text("회원가입이 완료되었습니다")
                    .font(.pretendSemiBold22)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.black)
                    .padding(.top, 10)

                // 서브 텍스트
                Text("이제 인데이비주얼에서 나만의 하루를 설계해 보세요!")
                    .font(.pretendMedium14)
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
            }
            Spacer()

            // 하단 버튼
            VStack {
                Button {
                    // TODO: 시작하기 동작
                } label: {
                    Text("시작하기")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -1)
            .padding(.bottom, 20)
        }
        .background(.white)
        .ignoresSafeArea()
    }
}

#Preview {
    SignupCompleteView()
}
