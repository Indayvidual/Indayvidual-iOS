//
//  SignupNicknameView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

//
//  SignupNicknameView.swift
//  Indayvidual
//

import SwiftUI

struct SignupNicknameView: View {
    @EnvironmentObject var viewModel: SignupViewModel
    @State private var nickname: String = ""
    @FocusState private var isNicknameFocused: Bool
    private let maxLength = 10
    @Environment(\.dismiss) private var dismiss
    @State private var goToNextStep = false
    @State private var isSigningUp = false
    @State private var localMessage: String? = nil

    // 공백만 있는 케이스 방지 위해 trim 후 판단
    var isNicknameValidLength: Bool {
        let trimmed = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty && trimmed.count <= maxLength
    }

    var body: some View {
        VStack(spacing: 28) {
            // 뒤로가기
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
            Text("인데이비주얼에서 사용할\n닉네임을 입력해주세요")
                .font(.pretendBold24)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.horizontal, 20)

            // 닉네임 입력
            VStack(spacing: 6) {
                HStack {
                    Text("닉네임")
                        .font(.pretendMedium13)
                    Spacer()
                    // 선택: 글자수 카운터
                    Text("\(nickname.count)/\(maxLength)")
                        .font(.pretendRegular12)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                CustomTextField(
                    placeholder: "닉네임",
                    text: $nickname,
                    isSecure: false,
                    // 입력 전엔 에러 X, 초과 시에만 에러
                    isError: !nickname.isEmpty && nickname.count > maxLength,
                    errorMessage: "10자 이하로 입력해주세요.",
                    showToggleSecure: false
                )
                .focused($isNicknameFocused)
                // 10자 초과 입력은 자동 컷
                .onChange(of: nickname) { _, newValue in
                    if newValue.count > maxLength {
                        nickname = String(newValue.prefix(maxLength))
                    }
                    // 에러 메시지는 여기서 별도 세팅하지 않음(위 isError 로직이 처리)
                    localMessage = nil
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // 하단 버튼 (여백 포함)
            VStack(spacing: 16) {
                Button {
                    guard isNicknameValidLength, !isSigningUp else { return }
                    isSigningUp = true
                    localMessage = nil

                    // 가입 진행
                    viewModel.nickname = nickname.trimmingCharacters(in: .whitespacesAndNewlines)
                    viewModel.signup { success in
                        isSigningUp = false
                        if success {
                            goToNextStep = true
                        } else {
                            localMessage = viewModel.errorMessage ?? "회원가입에 실패했습니다."
                        }
                    }
                } label: {
                    Text(isSigningUp ? "가입 중..." : "다음")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isNicknameValidLength ? Color.black : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(!isNicknameValidLength || isSigningUp)
                .padding(.horizontal, 20)

                if let localMessage {
                    Text(localMessage)
                        .font(.pretendRegular12)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                }
            }
            .padding(.top, 24)
            .padding(.bottom, 28)
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -1)
        }
        .navigationBarBackButtonHidden(true)
        .onTapGesture { hideKeyboard() }
        .navigationDestination(isPresented: $goToNextStep) {
            SignupCompleteView()
                .environmentObject(viewModel)
        }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

#Preview {
    SignupNicknameView()
        .environmentObject(SignupViewModel())
}
