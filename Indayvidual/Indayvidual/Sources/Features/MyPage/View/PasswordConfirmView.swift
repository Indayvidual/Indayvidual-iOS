//
//  PasswordConfirmView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//


import SwiftUI

struct PasswordConfirmView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = PasswordConfirmViewModel()
    
    @State private var password: String = ""
    @State private var showError: Bool = false
    @State private var errorText: String = "비밀번호가 일치하지 않거나 재인증에 실패했습니다."
    @State private var isVerifying = false
    @State private var didNavigate = false
    
    let onEmailVerified: (Profile) -> Void
    let onKakaoVerified: (Profile) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            HStack(spacing: 0) {
                Text("비밀번호 확인")
                    .font(.pretendSemiBold18)
                    .foregroundStyle(Color("gray-900"))
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark").foregroundStyle(Color("gray-900"))
                }
                .accessibilityLabel("닫기")
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(height: 52)
            
            Spacer().frame(height: 34)
            
            Image("lock-icon").resizable().frame(width: 54, height: 58)
            
            Spacer().frame(height: 16)
            
            Text("비밀번호를 입력해주세요").font(.pretendSemiBold22)
            
            Spacer().frame(height: 12)
            
            Text("개인정보 보호를 위해 비밀번호 확인이 필요합니다.")
                .font(.pretendRegular14)
                .foregroundStyle(Color("gray-500"))
            
            Spacer().frame(height: 50)
            
            CustomTextField(
                placeholder: "비밀번호",
                text: $password,
                isSecure: true,
                showToggleSecure: true
            )
            .textInputAutocapitalization(.never)
            
            Spacer().frame(height: 30)
            
            Button {
                guard !isVerifying, !didNavigate else { return }
                Task {
                    isVerifying = true
                    let profile = await viewModel.verifyPasswordAndFetchProfile(password)
                    isVerifying = false
                    
                    if let profile {
                        didNavigate = true
                        onEmailVerified(profile)
                    } else {
                        showError = true
                        errorText = viewModel.errorMessage ?? "재인증에 실패했어요."
                    }
                }
            } label: {
                Text(isVerifying ? "확인 중..." : "다음")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isVerifying ? Color.gray.opacity(0.4) : Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(isVerifying || password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            
            if showError {
                Text(errorText)
                    .font(.pretendRegular13)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
            
            Spacer()
            
            // 소셜 로그인 섹션
            VStack(spacing: 30) {
                HStack {
                    Rectangle().frame(height: 1).foregroundStyle(Color("gray-200"))
                    Text("소셜 로그인 회원의 경우")
                        .font(.pretendRegular13)
                        .foregroundStyle(Color("gray-500"))
                        .padding(.horizontal, 16)
                        .fixedSize(horizontal: true, vertical: false)
                    Rectangle().frame(height: 1).foregroundStyle(Color("gray-200"))
                }
                Button{
                    guard !isVerifying, !didNavigate else { return }
                    Task {
                        isVerifying = true
                        
                        let profile = await viewModel.kakaoReauthAndFetchProfile {
                            try await KakaoAuthService.shared.getAccessToken()
                        }
                        isVerifying = false
                        
                        if let profile {
                            didNavigate = true   
                            onKakaoVerified(profile)
                            
                        } else {
                            showError = true
                            errorText = viewModel.errorMessage ?? "재인증에 실패했어요."
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: "message.fill")
                        Text("카카오로 확인하기").font(.pretendMedium15)
                    }
                    .frame(maxWidth: .infinity).padding()
                    .foregroundStyle(Color("gray-900"))
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color("gray-200"), lineWidth: 1)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .padding(.horizontal, 20)
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .overlay {
            if isVerifying {
                ZStack {
                    Color.black.opacity(0.05).ignoresSafeArea()
                    ProgressView()
                        .padding(16)
                        .background(Color("gray-white"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}
