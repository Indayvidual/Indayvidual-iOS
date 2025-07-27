//
//  SignupNicknameView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct SignupNicknameView: View {
    @State private var nickname: String = ""
    @FocusState private var isNicknameFocused: Bool
    private let maxLength = 10

    var isNicknameValid: Bool {
        !nickname.isEmpty && nickname.count <= maxLength
    }

    var body: some View {
        VStack(spacing: 28) {
            // 뒤로가기
            HStack {
                Button {
                    // TODO: 뒤로가기 동작
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            // 타이틀
            Text("인데이비주얼에서 사용할\n닉네임을 입력해주세요")
                .font(.pretendBold24)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.horizontal, 20)

            // 닉네임 입력
            VStack(spacing: 5) {
                Text("닉네임")
                    .font(.pretendMedium13)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomTextField(
                    placeholder: "닉네임",
                    text: $nickname,
                    isSecure: false,
                    isError: nickname.count > maxLength,
                    errorMessage: "10자 이하로 입력해주세요.",
                    showToggleSecure: false
                )
                .focused($isNicknameFocused)
            }
            .padding(.horizontal, 20)

            Spacer()

            // 하단 버튼
            VStack {
                Button {
                    // 다음 단계로 이동
                } label: {
                    Text("다음")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isNicknameValid ? Color.black : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(!isNicknameValid)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -1)
        }
        // 키보드 올라올 때 뷰도 위로
        .padding(.bottom, isNicknameFocused ? 300 : 0)
        .animation(.easeOut(duration: 0.25), value: isNicknameFocused)
        .onTapGesture {
            hideKeyboard()
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupNicknameView()
}
