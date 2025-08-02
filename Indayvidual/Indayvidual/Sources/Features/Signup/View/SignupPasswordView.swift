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
    @State private var goToCodeView = false
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: SignupViewModel


    enum Field {
        case password
        case confirmPassword
    }

    var isPasswordValid: Bool {
        let regex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    var isConfirmMatched: Bool {
        return password == confirmPassword && !confirmPassword.isEmpty
    }

    var body: some View {
        VStack(spacing: 28) {
            // 상단 뒤로가기
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
                    isError: isPasswordEdited && !isPasswordValid,
                    errorMessage: "영문, 숫자, 특수기호를 모두 포함하여 입력해주세요.  (8글자 이상)",
                    showToggleSecure: true
                )
                .focused($focusedField, equals: .password)
                .onChange(of: password) {
                    isPasswordEdited = true
                }
                
                CustomTextField(
                    placeholder: "비밀번호 확인",
                    text: $confirmPassword,
                    isSecure: true,
                    isError: isPasswordEdited && !isConfirmMatched,
                    errorMessage: "비밀번호가 일치하지 않습니다.",
                    showToggleSecure: true
                )
                .focused($focusedField, equals: .confirmPassword)
                .onTapGesture {
                    isPasswordEdited = true
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            // 하단 버튼
            VStack {
                NavigationLink(destination: SignupNicknameView().environmentObject(viewModel), isActive: $goToCodeView) {
                                Button {
                                    viewModel.password = password
                                    goToCodeView = true
                                } label: {
                        Text("다음")
                            .font(.pretendSemiBold15)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isPasswordValid && isConfirmMatched ? Color.black : Color.gray.opacity(0.3))
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .disabled(!(isPasswordValid && isConfirmMatched))
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                .background(.white)
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: -5)
            }
            .padding(.top, 40)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupPasswordView()
}
