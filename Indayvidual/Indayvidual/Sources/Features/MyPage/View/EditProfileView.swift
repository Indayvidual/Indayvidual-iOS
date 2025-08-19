//
//  EditProfileView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

//
//  EditProfileView.swift
//  Indayvidual
//
//  요구사항 반영:
//  1) 이메일 비편집(읽기전용)
//  2) 로그아웃/탈퇴 모달 확인 후 실행 → LoginView 이동
//  3) 저장 시 MypageView 이동 + 토스트 3초
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = EditProfileViewModel()

    // 전달받은 Profile로 초기화
    @State private var nickname: String
    @State private var email: String
    @State private var imageUrl: String?

    // 닉네임 버튼 상태
    @State private var isNicknameChanged: Bool = false
    @State private var isNicknameButtonEnabled: Bool = false

    // 비밀번호 편집 영역 상태
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEditingPassword: Bool = false
    @FocusState private var focusedField: Field?
    @State private var isPasswordEdited = false
    enum Field { case password, confirmPassword }

    // 모달 & 네비게이션 상태
    @State private var showLogoutConfirm = false
    @State private var showWithdrawConfirm = false
    @State private var goLogin = false
    @State private var goMypage = false

    // 저장 성공 콜백(선택)
    var onSaved: (() -> Void)?

    init(profile: Profile, onSaved: (() -> Void)? = nil) {
        _nickname = State(initialValue: profile.nickname ?? "")
        _email    = State(initialValue: profile.email ?? "")
        _imageUrl = State(initialValue: profile.imageUrl)
        self.onSaved = onSaved
    }

    // 비밀번호 유효성
    var isPasswordValid: Bool {
        let regex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    var isConfirmMatched: Bool {
        password == confirmPassword && !confirmPassword.isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("gray-50").ignoresSafeArea()

            // 네비게이션 (Login / Mypage)
            NavigationLink("", destination: LoginView().navigationBarBackButtonHidden(true),
                           isActive: $goLogin).hidden()
            NavigationLink("", destination: MyPageView(showEditToast: true).navigationBarBackButtonHidden(true),
                           isActive: $goMypage).hidden()

            VStack(spacing: 0) {
                // 헤더
                HStack(spacing: 10) {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                    }
                    Text("내 정보 수정")
                        .font(.pretendSemiBold18)
                        .foregroundStyle(Color("gray-900"))
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 13)
                .background(Color("gray-white"))

                // 본문
                ScrollView {
                    VStack(spacing: 10) {
                        // 기본 정보 카드
                        VStack(alignment: .leading, spacing: 8) {
                            Text("기본 정보")
                                .font(.pretendSemiBold18)

                            Spacer().frame(height: 16)

                            Text("프로필 사진")
                                .font(.pretendRegular13)

                            VStack(spacing: 20) {
                                if let urlStr = imageUrl, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView().frame(width: 80, height: 80)
                                        case .success(let img):
                                            img
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        default:
                                            Image("profile")
                                                .resizable()
                                                .frame(width: 80, height: 80)
                                                .clipShape(Circle())
                                        }
                                    }
                                } else {
                                    Image("profile")
                                        .resizable()
                                        .frame(width: 80, height: 80)
                                        .clipShape(Circle())
                                }

                                Text("인데이비주얼에서 사용할 프로필 사진을 등록해주세요.")
                                    .font(.pretendSemiBold13)
                                    .foregroundStyle(Color("gray-900"))

                                HStack(spacing: 8) {
                                    Button("기본 이미지로 변경") {
                                        imageUrl = "https://indayvidual.s3.ap-northeast-2.amazonaws.com/base_image.png"
                                    }
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity)            // ✅ frame 분리
                                    .frame(height: 40)
                                    .foregroundStyle(Color("gray-900"))
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("gray-200"), lineWidth: 1)
                                    }

                                    Button("이미지 변경") {
                                        // TODO: 이미지 피커 → 업로드 API
                                    }
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity)            // ✅ frame 분리
                                    .frame(height: 40)
                                    .foregroundStyle(Color("gray-900"))
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color("gray-200"), lineWidth: 1)
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Spacer().frame(height: 10)

                            // 닉네임
                            VStack(alignment: .leading, spacing: 8) {
                                Text("닉네임")
                                    .font(.pretendMedium14)
                                    .foregroundStyle(Color("gray-900"))

                                HStack {
                                    TextField("", text: $nickname)
                                        .padding(.horizontal, 16)
                                        .frame(height: 48)
                                        .background(Color("gray-50"))
                                        .cornerRadius(8)
                                        .onChange(of: nickname) { _, _ in
                                            isNicknameChanged = true
                                            isNicknameButtonEnabled = true
                                        }

                                    Button("변경하기") {
                                        viewModel.updateNickname(nickname: nickname)
                                    }
                                    .font(.pretendMedium14)
                                    .padding(.horizontal, 24)
                                    .frame(height: 48)
                                    .background(Color("primary-light"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(8)
                                    .disabled(!isNicknameButtonEnabled)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(20)
                        .background(Color("gray-white"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // 회원 정보 카드
                        VStack(alignment: .leading, spacing: 24) {
                            Text("회원 정보")
                                .font(.pretendSemiBold16)

                            // 이메일(읽기 전용)
                            VStack(alignment: .leading, spacing: 8) {
                                Text("이메일")
                                    .font(.pretendMedium14)
                                    .foregroundStyle(Color("gray-900"))

                                Text(email)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .frame(height: 48)
                                    .background(Color("gray-50"))
                                    .cornerRadius(8)
                            }

                            // 비밀번호
                            VStack(alignment: .leading, spacing: 8) {
                                Text("비밀번호")
                                    .font(.pretendMedium14)
                                    .foregroundStyle(Color("gray-900"))

                                if isEditingPassword {
                                    VStack(spacing: 12) {
                                        CustomTextField(
                                            placeholder: "영문, 숫자, 특수기호 모두 포함 (8글자 이상)",
                                            text: $password,
                                            isSecure: true,
                                            isError: isPasswordEdited && !isPasswordValid,
                                            errorMessage: "영문, 숫자, 특수기호를 모두 포함하여 입력해주세요.  (8글자 이상)",
                                            showToggleSecure: true
                                        )
                                        .focused($focusedField, equals: .password)
                                        .onTapGesture { isPasswordEdited = true }

                                        CustomTextField(
                                            placeholder: "새 비밀번호 확인",
                                            text: $confirmPassword,
                                            isSecure: true,
                                            isError: isPasswordEdited && !isConfirmMatched,
                                            errorMessage: "비밀번호가 일치하지 않습니다.",
                                            showToggleSecure: true
                                        )
                                        .focused($focusedField, equals: .confirmPassword)
                                        .onTapGesture { isPasswordEdited = true }
                                    }

                                    Button("비밀번호 변경 취소") {
                                        isEditingPassword = false
                                        password = ""
                                        confirmPassword = ""
                                    }
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity)            // ✅ frame 분리
                                    .frame(height: 48)
                                    .background(Color("primary-light"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(10)

                                } else {
                                    Button("비밀번호 변경하기") {
                                        isEditingPassword = true
                                    }
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity)            // ✅ frame 분리
                                    .frame(height: 48)
                                    .background(Color("primary-light"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color("gray-white"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // 하단 로그아웃 / 회원탈퇴 (모달 확인)
                        HStack(spacing: 120 ) {
                            Button("로그아웃") { showLogoutConfirm = true }
                                .foregroundStyle(Color("gray-500"))

                            Button("탈퇴", role: .destructive) { showWithdrawConfirm = true }
                                .foregroundStyle(Color("gray-900"))
                        }
                        .font(.pretendMedium14)
                        .padding(.horizontal, 50)
                        .padding(.vertical, 15)

                        Spacer().frame(height: 10)
                    }
                }

                // 하단 버튼
                HStack(spacing: 12) {
                    Button("취소") { goMypage = true }
                        .frame(maxWidth: .infinity)                // ✅ frame 분리
                        .frame(height: 48)
                        .background(Color("gray-white"))
                        .foregroundStyle(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("gray-200"), lineWidth: 1)
                        )

                    Button("저장") {
                        onSaved?()
                        goMypage = true   // 저장 후 MypageView로 이동
                    }
                    .frame(maxWidth: .infinity)                    // ✅ frame 분리
                    .frame(height: 48)
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color("gray-white"))
            }
        }
        .navigationBarBackButtonHidden(true)

        // 로그아웃 확인 모달
        .overlay {
            if showLogoutConfirm {
                ConfirmModal(
                    title: "로그아웃 하시겠습니까?",
                    message: nil,
                    confirmText: "확인",
                    confirmStyle: .dark,
                    onCancel: { showLogoutConfirm = false },
                    onConfirm: {
                        showLogoutConfirm = false
                        userSession.clear()
                        goLogin = true
                    }
                )
            }
        }
        // 회원탈퇴 확인 모달
        .overlay {
            if showWithdrawConfirm {
                ConfirmModal(
                    title: "탈퇴 하시겠습니까?",
                    message: "탈퇴시 계정은 삭제되며, 복구되지 않습니다.",
                    confirmText: "탈퇴",
                    confirmStyle: .destructive,
                    onCancel: { showWithdrawConfirm = false },
                    onConfirm: {
                        viewModel.deleteAccount(hard: false) { _ in
                            showWithdrawConfirm = false
                            userSession.clear()
                            goLogin = true
                        }
                    }
                )
            }
        }
    }
}

// MARK: - 확인 모달
struct ConfirmModal: View {
    enum ConfirmStyle { case dark, destructive }
    var title: String
    var message: String?
    var confirmText: String
    var confirmStyle: ConfirmStyle = .dark
    var onCancel: () -> Void
    var onConfirm: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45).ignoresSafeArea()
            VStack(spacing: 16) {
                Text(title)
                    .font(.pretendSemiBold16)
                    .foregroundStyle(Color("gray-900"))
                    .multilineTextAlignment(.center)

                if let message {
                    Text(message)
                        .font(.pretendRegular13)
                        .foregroundStyle(Color("gray-600"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 6)
                }

                HStack(spacing: 12) {
                    Button("취소", action: onCancel)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("gray-white"))
                        .foregroundStyle(Color("gray-900"))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("gray-200"), lineWidth: 1))
                        .cornerRadius(10)

                    Button(confirmText, action: onConfirm)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(confirmStyle == .destructive ? Color.red : Color.black)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding(20)
            .frame(maxWidth: 300)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .transition(.opacity)
    }
}

// MARK: - 미리보기
#Preview {
    NavigationStack {
        EditProfileView(
            profile: .init(userId: 1, email: "test@example.com", nickname: "데모", imageUrl: nil)
        )
        .environmentObject(UserSession())
    }
}
