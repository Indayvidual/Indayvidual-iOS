//
//  SignupPasswordView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct SignupPasswordView: View {
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @FocusState private var focusedField: Field?
    @State private var isPasswordEdited = false
    @State private var goToNickname = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: SignupViewModel

    enum Field { case password, confirmPassword }

    var isPasswordValid: Bool {
        let regex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    var isConfirmMatched: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                // 상단 뒤로가기
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.black)
                            .imageScale(.large)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)

                // 타이틀
                Text("비밀번호를\n설정해주세요")
                    .font(.pretendBold24)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.horizontal, 20)

                // 입력 필드
                VStack(spacing: 12) {
                    Text("비밀번호")
                        .font(.pretendMedium13)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    CustomTextField(
                        placeholder: "비밀번호",
                        text: $password,
                        isSecure: true,
                        isError: isPasswordEdited && !password.isEmpty && !isPasswordValid,
                        errorMessage: "영문, 숫자, 특수기호를 모두 포함하여 입력해주세요. (8글자 이상)",
                        showToggleSecure: true
                    )
                    .focused($focusedField, equals: .password)
                    .onChange(of: password) { _, _ in
                        isPasswordEdited = true
                    }

                    CustomTextField(
                        placeholder: "비밀번호 확인",
                        text: $confirmPassword,
                        isSecure: true,
                        isError: isPasswordEdited && !confirmPassword.isEmpty && !isConfirmMatched,
                        errorMessage: "비밀번호가 일치하지 않습니다.",
                        showToggleSecure: true
                    )
                    .focused($focusedField, equals: .confirmPassword)
                    .onChange(of: confirmPassword) { _, _ in
                        isPasswordEdited = true
                    }
                }
                .padding(.horizontal, 20)

                Spacer(minLength: 0)
            }
            .padding(.bottom, 16) // 스크롤 영역 여유
        }
        .navigationBarBackButtonHidden(true)
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 16) {
                Button {
                    guard isPasswordValid && isConfirmMatched else { return }
                    viewModel.password = password
                    goToNickname = true
                } label: {
                    Text("다음")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isPasswordValid && isConfirmMatched ? Color.black : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .disabled(!(isPasswordValid && isConfirmMatched))
                .padding(.horizontal, 20)
            }
            .padding(.top, 24)
            .padding(.bottom, 28)
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -5)
        }
        .onTapGesture { hideKeyboard() }
        // 키보드가 올라와도 레이아웃 유지 (하단 인셋이 알아서 대응)
        .ignoresSafeArea(.keyboard, edges: []) // 기본값 유지해도 OK
        .navigationDestination(isPresented: $goToNickname) {
            SignupNicknameView()
                .environmentObject(viewModel)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupPasswordView()
        .environmentObject(SignupViewModel())
}
