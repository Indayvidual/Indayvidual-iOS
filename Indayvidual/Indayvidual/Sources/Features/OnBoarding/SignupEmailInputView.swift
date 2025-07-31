//
//  SignupEmailInputView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct SignupEmailInputView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var isEmailFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var goToCodeView = false

    var body: some View {
        VStack(spacing: 28) {
            // 상단 네비게이션
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image("back-icon")
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            // 타이틀
            Text("이메일을\n입력해주세요")
                .font(.pretendBold24)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.horizontal, 20)

            // 이메일 입력
            VStack(spacing: 5) {
                Text("이메일")
                    .font(.pretendMedium13)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomTextField(
                    placeholder: "이메일",
                    text: $viewModel.email,
                    isSecure: false,
                    isError: !viewModel.isValidEmail,
                    errorMessage: "올바른 이메일 형식이 아닙니다.",
                    showToggleSecure: false
                )
                .focused($isEmailFocused)  // 포커스 적용
            }
            .padding(.horizontal, 20)

            Spacer()

            // 하단 버튼
            VStack {
                HStack {
                    NavigationLink(destination: SignupEmailCodeView(), isActive: $goToCodeView) {
                        Button {
                            goToCodeView = true
                        } label: {
                            Text("다음")
                                .font(.pretendSemiBold15)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(viewModel.isValidEmail ? Color.black : Color.gray.opacity(0.3))
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                        .disabled(!viewModel.isValidEmail)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -1)
        }
        .navigationBarBackButtonHidden(true)
    }

    // 키보드 내리기 (터치 시)
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


#Preview {
    SignupEmailInputView()
}
