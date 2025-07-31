//
//  PasswordConfirmView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct PasswordConfirmView: View {
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var goToNextView = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Text("비밀번호 확인")
                    .font(.pretendSemiBold18)
                    .foregroundStyle(Color("gray-900"))
                
                Spacer()
                
                // 상단 닫기 버튼
                Button(action: {
                    // 닫기 액션
                }) {
                    Image(systemName: "xmark")
                        .foregroundStyle(Color("gray-900"))
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(height: 52)

            Spacer()
                .frame(height: 34)

            // 자물쇠 아이콘
            Image("lock-icon")
                .resizable()
                .frame(width: 54, height: 58)
            
            Spacer()
                .frame(height: 16)

            // 안내 텍스트
            Text("비밀번호를 입력해주세요")
                .font(.pretendSemiBold22)
            
            Spacer()
                .frame(height: 12)

            Text("개인정보 보호를 위해 비밀번호 확인이 필요합니다.")
                .font(.pretendRegular14)
                .foregroundStyle(Color("gray-500"))
            
            Spacer()
                .frame(height: 50)

            // 커스텀 텍스트 필드
            CustomTextField(
                placeholder: "비밀번호", text: $password,
                isSecure: true,
                showToggleSecure: true
            )
            
            Spacer()
                .frame(height: 30)

            // 다음 버튼
            VStack {
                NavigationLink(destination: EditProfileView(), isActive: $goToNextView) {
                    Button(action: {
                        goToNextView = true // 비밀번호와 관계없이 바로 이동
                    }) {                Text("다음")
                            .font(.system(size: 16, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }

            Spacer()

            // 소셜 로그인 안내
            VStack(spacing: 30) {
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("gray-200"))
                    Text("소셜 로그인 회원의 경우")
                        .font(.pretendRegular13)
                        .foregroundStyle(Color("gray-500"))
                        .padding(.horizontal, 16)
                        .fixedSize(horizontal: true, vertical: false)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("gray-200"))
                }
                
                Button(action: {
                    // 카카오 인증 액션
                }) {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("카카오로 확인하기")
                            .font(.pretendMedium15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(Color("gray-900"))
                    .background(alignment: .center) {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color("gray-200"), lineWidth: 1)
                        }
                }
            }
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    PasswordConfirmView()
}
