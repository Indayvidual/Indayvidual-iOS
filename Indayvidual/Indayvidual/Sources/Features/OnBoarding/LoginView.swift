//
//  LoginView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/26/25.
//

import SwiftUI

enum AuthTab {
    case login
    case signup
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var isPasswordEdited = false
    @State private var selectedTab: AuthTab = .login
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var autoLogin: Bool = false
    @State private var isPasswordVisible = false

    // MARK: - 로그인 뷰
    var loginForm: some View {
        VStack(spacing: 20) {
            CustomTextField(
                placeholder: "이메일",
                text: $viewModel.email,
                isSecure: false,
                isError: !viewModel.isValidEmail,
                errorMessage: "올바른 이메일 형식이 아닙니다."
            )
            
            CustomTextField(
                placeholder: "비밀번호",
                text: $viewModel.password,
                isSecure: true,
                isError: isPasswordEdited && viewModel.password.isEmpty,
                errorMessage: "비밀번호를 입력해주세요.",
                showToggleSecure: true
            )
            .onTapGesture {
                self.isPasswordEdited = true
            }
            
            HStack {
                Toggle("자동로그인", isOn: $viewModel.autoLogin)
                    .toggleStyle(CheckboxToggleStyle())
                    .font(.pretendMedium13)
                    .foregroundStyle(.black)
                Spacer()
            }
            
            VStack(spacing: 40) {
                Button {
                    viewModel.login()
                } label: {
                    Text("로그인")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.black)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                }
                
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("gray-200"))
                    Text("또는")
                        .foregroundStyle(Color("gray-500"))
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(Color("gray-200"))
                }
                
                Button {
                    // TODO: 카카오 로그인
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("카카오로 시작하기")
                            .font(.pretendSemiBold15)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color("yellow-04"))
                    .foregroundStyle(.black)
                    .cornerRadius(8)
                }
            }
            .padding(.top, 10)
        }
    }
    // MARK: - 회원가입 뷰
    var signupIntro: some View {
        VStack(spacing: 50) {
            Button {
                // 이메일로 시작
            } label: {
                Text("이메일로 시작하기")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray.opacity(0.3))
                Text("또는")
                    .foregroundStyle(.gray)
                    .padding(.horizontal, 8)
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.gray.opacity(0.3))
            }

            Button {
                // 카카오 회원가입
            } label: {
                HStack {
                    Image(systemName: "message.fill")
                    Text("카카오로 시작하기")
                        .font(.system(size: 15, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("yellow-04"))
                .foregroundStyle(.black)
                .cornerRadius(12)
            }

            Spacer()
            Text("개인정보 처리방침")
                .font(.pretendMedium13)
                .foregroundStyle(.gray)
                .underline()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - 탭 버튼
    private func tabButton(title: String, tab: AuthTab) -> some View {
        Button {
            selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(selectedTab == tab ? .black : .gray)

                Rectangle()
                    .frame(height: 2)
                    .foregroundStyle(selectedTab == tab ? .black : .gray.opacity(0.3))
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - body
    var body: some View {
        VStack(spacing: 28) {
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

            Text(selectedTab == .login ? "인데이비주얼과 함께\n나만의 하루를 설계하기" :
                 "회원가입하고\n나만의 하루를 설계해 보세요!")
                .font(.pretendBold24)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                tabButton(title: "로그인", tab: .login)
                tabButton(title: "회원가입", tab: .signup)
            }
            

            if selectedTab == .login {
                loginForm
                    .padding(.top, 20)
            } else {
                signupIntro
                    .padding(.top, 30)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
    }
}


struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(spacing: 8) {
            Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .foregroundStyle(configuration.isOn ? Color("button-color") : .gray)
                .onTapGesture {
                    configuration.isOn.toggle()
                }

            configuration.label
        }
    }
}

#Preview {
    LoginView()
}
