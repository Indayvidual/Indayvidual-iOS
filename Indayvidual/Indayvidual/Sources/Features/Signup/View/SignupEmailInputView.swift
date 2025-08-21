//
//  SignupEmailInputView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct SignupEmailInputView: View {
    @EnvironmentObject var viewModel: SignupViewModel
    @FocusState private var isEmailFocused: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var goToCodeView = false
    @State private var isChecking = false
    @State private var localMessage: String? = nil

    var body: some View {
        VStack(spacing: 28) {
            // 상단 네비게이션
            HStack {
                Button { dismiss() } label: { Image(systemName: "chevron.left")
                    .foregroundStyle(.black)}
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
            VStack(spacing: 6) {
                Text("이메일")
                    .font(.pretendMedium13)
                    .frame(maxWidth: .infinity, alignment: .leading)

                CustomTextField(
                    placeholder: "이메일",
                    text: $viewModel.email,
                    isSecure: false,
                    isError: (!viewModel.email.isEmpty && !viewModel.isValidEmail),
                    errorMessage: "올바른 이메일 형식이 아닙니다.",
                    showToggleSecure: false
                )
                .focused($isEmailFocused)

                Group {
                    if viewModel.email.isEmpty {
                        EmptyView() // 아무 것도 표시하지 않음
                    } else if !viewModel.isValidEmail {
                        // 형식 에러는 CustomTextField에서 이미 빨간 문구 노출 중
                        EmptyView()
                    } else {
                        // 형식은 맞는 상태 → 서버 체크 결과 표시
                        switch viewModel.emailCheckStatus {
                        case .some(.duplicate):
                            Text("이미 가입된 이메일입니다.")
                                .font(.pretendRegular12)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        case .some(.available):
                            Text("가입 가능한 이메일입니다.")
                                .font(.pretendRegular12)
                                .foregroundStyle(.green)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        case .some(.failed(let msg)):
                            Text(msg)
                                .font(.pretendRegular12)
                                .foregroundStyle(.red)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        case .none:
                            // 아직 체크 전이면 표시 안 함
                            EmptyView()
                        }
                    }
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // 하단 버튼
            VStack(spacing: 16) {
                Button {
                    guard !viewModel.email.isEmpty, viewModel.isValidEmail, !isChecking else { return }
                    isChecking = true
                    localMessage = nil

                    // 이메일 중복 검사 → 가능하면 코드 전송 후 다음 화면
                    viewModel.checkEmail { available in
                        isChecking = false
                        if available {
                            // UI에도 성공 라벨 노출
                            viewModel.emailCheckStatus = .available
                            viewModel.sendVerificationCode()
                            goToCodeView = true
                        } else {
                        }
                    }
                } label: {
                    Text(isChecking ? "확인 중..." : "다음")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background((viewModel.isValidEmail && !viewModel.email.isEmpty) ? Color.black : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(viewModel.email.isEmpty || !viewModel.isValidEmail || isChecking)
                .padding(.horizontal, 20)
            }
            .padding(.top, 24)
            .padding(.bottom, 28)
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -1)
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $goToCodeView) {
            SignupEmailCodeView()
                .environmentObject(viewModel)
        }
        // 이메일을 수정하면 서버 체크 결과 초기화
        .onChange(of: viewModel.email) { _, _ in
            viewModel.emailCheckStatus = nil
            viewModel.errorMessage = nil
        }
    }

    // 키보드 내리기 (터치 시)
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupEmailInputView()
        .environmentObject(SignupViewModel())
}
