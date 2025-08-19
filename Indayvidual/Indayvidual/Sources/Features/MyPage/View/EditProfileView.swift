//
//  EditProfileView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI
import PhotosUI
import UIKit

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = EditProfileViewModel()
    
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var localPreview: UIImage? = nil

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
    @State private var currentPassword: String = ""
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
        content
            .navigationBarBackButtonHidden(true)
            .fullScreenCover(isPresented: $goLogin) {
                NavigationStack { LoginView().navigationBarBackButtonHidden(true) }
            }
            .fullScreenCover(isPresented: $goMypage) {
                NavigationStack { MyPageView(showEditToast: true).navigationBarBackButtonHidden(true) }
            }
            // 모달 오버레이 분리
            .overlay(logoutOverlay)
            .overlay(withdrawOverlay)
    }
}

// MARK: - Content split (타입체커 부담 ↓)
extension EditProfileView {
    private var content: some View {
        ZStack(alignment: .top) {
            Color("gray-50").ignoresSafeArea()
            VStack(spacing: 0) {
                headerView
                ScrollView { scrollContent }
                footerButtons
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 10) {
            Button { dismiss() } label: { Image(systemName: "chevron.left") }
            Text("내 정보 수정")
                .font(.pretendSemiBold18)
                .foregroundStyle(Color("gray-900"))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(Color("gray-white"))
    }

    private var scrollContent: some View {
        VStack(spacing: 10) {
            basicInfoCard
            memberInfoCard
            actionRow
            Spacer().frame(height: 10)
        }
    }

    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("기본 정보").font(.pretendSemiBold18)
            Spacer().frame(height: 16)
            Text("프로필 사진").font(.pretendRegular13)

            VStack(spacing: 20) {
                profileImage
                Text("인데이비주얼에서 사용할 프로필 사진을 등록해주세요.")
                    .font(.pretendSemiBold13)
                    .foregroundStyle(Color("gray-900"))
                HStack(spacing: 8) {
                    borderedButton(title: "기본 이미지로 변경") {
                        imageUrl = "https://indayvidual.s3.ap-northeast-2.amazonaws.com/base_image.png"
                    }

                    // ✅ PhotosPicker 버튼 (bordered 스타일 그대로)
                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("이미지 변경")
                            .font(.pretendMedium14)
                            .frame(maxWidth: .infinity)
                            .frame(height: 40)
                            .foregroundStyle(Color("gray-900"))
                            .background {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color("gray-200"), lineWidth: 1)
                            }
                    }
                }
                .onChange(of: selectedItem) { _, item in
                    guard let item = item else { return }
                    Task {
                        // 1) Data 로드
                        guard let data = try? await item.loadTransferable(type: Data.self) else {
                            viewModel.toastMessage = "이미지를 불러오지 못했습니다."
                            return
                        }
                        // 2) 즉시 미리보기
                        if let ui = UIImage(data: data) {
                            await MainActor.run { self.localPreview = ui }
                        }
                        // 3) 파일명 추정 (확장자 모르면 jpg)
                        let filename = (item.itemIdentifier ?? "profile") + ".jpg"

                        // 4) 업로드 API 호출
                        viewModel.uploadProfileImage(data, filename: filename) {
                            // (선택) 서버 반영 후 미리보기 클리어
                            self.localPreview = nil
                            // 필요 시 여기서 프로필 재조회 후 imageUrl 갱신:
                            // viewModel.fetchMyProfile { p in self.imageUrl = p?.imageUrl }
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer().frame(height: 10)

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

                    Button("변경하기") { viewModel.updateUsername(nickname) }
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
    }

    private var profileImage: some View {
        Group {
            if let preview = localPreview {
                Image(uiImage: preview)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            } else if let urlStr = imageUrl, let url = URL(string: urlStr) {
                RemoteAvatar(url: url)
            } else {
                Image("profile")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
        }
    }


    private var memberInfoCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("회원 정보").font(.pretendSemiBold16)

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

            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호")
                    .font(.pretendMedium14)
                    .foregroundStyle(Color("gray-900"))

                if isEditingPassword { passwordEditingBlock } else { passwordEditButton }
            }
        }
        .padding(20)
        .background(Color("gray-white"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var passwordEditingBlock: some View {
        VStack(spacing: 12) {
            CustomTextField(
                placeholder: "영문, 숫자, 특수기호 모두 포함 (8글자 이상)",
                text: $currentPassword,
                isSecure: true,
                isError: isPasswordEdited && currentPassword.isEmpty,
                errorMessage: "영문, 숫자, 특수기호를 모두 포함하여 입력해주세요.  (8글자 이상)",
                showToggleSecure: true
            )
            .focused($focusedField, equals: .password)
            .onTapGesture { isPasswordEdited = true }

            CustomTextField(
                placeholder: "새 비밀번호 확인",
                text: $password,
                isSecure: true,
                isError: isPasswordEdited && !isConfirmMatched,
                errorMessage: "비밀번호가 일치하지 않습니다.",
                showToggleSecure: true
            )
            
            CustomTextField(
                        placeholder: "새 비밀번호 확인",
                        text: $confirmPassword,
                        isSecure: true,
                        isError: isPasswordEdited && !isConfirmMatched,
                        errorMessage: "비밀번호가 일치하지 않습니다.",
                        showToggleSecure: true
                    )
            
            primaryBlockButton("비밀번호 변경 완료") {
                isPasswordEdited = true
                guard !currentPassword.isEmpty else { return }
                guard isPasswordValid && isConfirmMatched else { return }
                
                viewModel.changePassword(current: currentPassword, new: password) { ok in
                    if ok {
                        isEditingPassword = false
                        currentPassword = ""
                        password = ""
                        confirmPassword = ""
                    }
                }
            }
                    .disabled(currentPassword.isEmpty || !isPasswordValid || !isConfirmMatched)

            primaryBlockButton("비밀번호 변경 취소") {
                isEditingPassword = false
                password = ""
                confirmPassword = ""
            }
        }
    }

    private var passwordEditButton: some View {
        primaryBlockButton("비밀번호 변경하기") { isEditingPassword = true }
    }

    private var actionRow: some View {
        HStack(spacing: 120) {
            Button("로그아웃") { showLogoutConfirm = true }
                .foregroundStyle(Color("gray-500"))
            Button("탈퇴", role: .destructive) { showWithdrawConfirm = true }
                .foregroundStyle(Color("gray-900"))
        }
        .font(.pretendMedium14)
        .padding(.horizontal, 50)
        .padding(.vertical, 15)
    }

    private var footerButtons: some View {
        HStack(spacing: 12) {
            borderedBlockButton("취소") { goMypage = true }
            solidBlockButton("저장") {
                onSaved?()
                goMypage = true
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color("gray-white"))
    }
}

// MARK: - Reusable pieces
extension EditProfileView {
    private func borderedButton(title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.pretendMedium14)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .foregroundStyle(Color("gray-900"))
            .background { RoundedRectangle(cornerRadius: 8).stroke(Color("gray-200"), lineWidth: 1) }
    }

    private func primaryBlockButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .font(.pretendMedium14)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color("primary-light"))
            .foregroundStyle(.black)
            .cornerRadius(10)
    }

    private func borderedBlockButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color("gray-white"))
            .foregroundStyle(.black)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("gray-200"), lineWidth: 1))
            .cornerRadius(12)
    }

    private func solidBlockButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(title, action: action)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.black)
            .foregroundStyle(.white)
            .cornerRadius(12)
    }
}

// MARK: - Overlays (분리)
extension EditProfileView {
    private var logoutOverlay: some View {
        Group {
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
    }

    private var withdrawOverlay: some View {
        Group {
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

// MARK: - RemoteAvatar (AsyncImage 분리로 타입체커 부담 ↓)
private struct RemoteAvatar: View {
    let url: URL
    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView().frame(width: 80, height: 80)
            case .success(let img):
                img.resizable().frame(width: 80, height: 80).clipShape(Circle())
            default:
                Image("profile").resizable().frame(width: 80, height: 80).clipShape(Circle())
            }
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        EditProfileView(
            profile: .init(userId: 1, email: "test@example.com", nickname: "데모", imageUrl: nil)
        )
        .environmentObject(UserSession())
    }
}
