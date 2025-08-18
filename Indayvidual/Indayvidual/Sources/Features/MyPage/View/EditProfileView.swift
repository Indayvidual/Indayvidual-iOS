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
    @State private var showLogin = false

    // 전달받은 Profile로 초기화
    @State private var nickname: String
    @State private var email: String
    @State private var imageUrl: String?

    // 닉네임 상태
    @State private var nicknameDebounceTask: Task<Void, Never>? = nil

    // 비번 상태
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEditingPassword: Bool = false
    @State private var isPasswordEdited: Bool = false
    @FocusState private var focusedField: Field?
    enum Field { case password, confirmPassword }

    // 이미지 선택
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var localPreview: UIImage? = nil

    // 탈퇴 결과
    @State private var showDeleteResult = false
    @State private var deleteResultMessage: String = ""

    // 유효성
    var isPasswordValid: Bool {
        let regex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    var isConfirmMatched: Bool { password == confirmPassword && !confirmPassword.isEmpty }

    // init
    var onSaved: (() -> Void)?

    init(profile: Profile, onSaved: (() -> Void)? = nil) {
        _nickname = State(initialValue: profile.nickname ?? "")
        _email    = State(initialValue: profile.email ?? "")
        _imageUrl = State(initialValue: profile.imageUrl)
        self.onSaved = onSaved
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("gray-50").ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: 10) {
                        basicInfoCard
                        accountCard
                        deleteRow
                    }
                    .padding(.vertical, 12)
                }

                footer
            }
        }
        .navigationBarBackButtonHidden(true)
        .alert("알림", isPresented: $showDeleteResult) {
            Button("확인", role: .cancel) { }
        } message: {
            Text(deleteResultMessage)
        }
        .onChange(of: selectedItem) { _, item in
            if let item { handlePicked(item) }
        }
    }

    // MARK: - Sections

    private var header: some View {
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

    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("기본 정보").font(.pretendSemiBold18)
            Spacer().frame(height: 16)

            Text("프로필 사진").font(.pretendRegular13)

            VStack(spacing: 20) {
                ProfileImageBubble(localPreview: localPreview, imageUrl: imageUrl)

                Text("인데이비주얼에서 사용할 프로필 사진을 등록해주세요.")
                    .font(.pretendSemiBold13)
                    .foregroundStyle(Color("gray-900"))

                HStack(spacing: 8) {
                    Button("기본 이미지로 변경") {
                        viewModel.fetchMyProfile { p in
                                if let u = p?.imageUrl {
                                    self.imageUrl = bustCache(u)
                                } else {
                                    self.imageUrl = nil
                                }
                                self.localPreview = nil
                            }
                        }
                    .font(.pretendMedium14)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .foregroundStyle(Color("gray-900"))
                    .background { RoundedRectangle(cornerRadius: 8).stroke(Color("gray-200"), lineWidth: 1) }

                    PhotosPicker(selection: $selectedItem, matching: .images) {
                        Text("이미지 변경")
                            .font(.pretendMedium14)
                            .frame(maxWidth: .infinity, minHeight: 40)
                            .foregroundStyle(Color("gray-900"))
                            .background { RoundedRectangle(cornerRadius: 8).stroke(Color("gray-200"), lineWidth: 1) }
                    }
                }
            }

            Spacer().frame(height: 10)

            Text("닉네임").font(.pretendMedium14).foregroundStyle(Color("gray-900"))
            HStack(spacing: 8) {
                TextField("", text: $nickname)
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(Color("gray-50"))
                    .cornerRadius(8)
                    .onChange(of: nickname) { _, newValue in
                        scheduleNicknameCheck(newValue)
                    }

                Button {
                    viewModel.updateUsername(nickname) {
                        // 성공 시 즉시 서버 기준 동기화가 필요하면 여기서 fetch 호출
                        // viewModel.fetchMyProfile { p in nickname = p?.username ?? nickname }
                    }
                } label: {
                    if viewModel.isUpdatingUsername {
                        ProgressView().frame(width: 20, height: 20)
                    } else {
                        Text("변경하기").font(.pretendMedium14)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(Color("primary-light"))
                .foregroundStyle(.black)
                .cornerRadius(8)
                .disabled(!(viewModel.isUsernameAvailable ?? true) || viewModel.isCheckingUsername || nickname.isEmpty)
            }

            if let msg = viewModel.usernameCheckMessage {
                Text(msg)
                    .font(.pretendRegular12)
                    .foregroundStyle((viewModel.isUsernameAvailable ?? false) ? .green : .red)
            }
        }
        .padding(20)
        .background(Color("gray-white"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var accountCard: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("회원 정보").font(.pretendSemiBold16)

            VStack(alignment: .leading, spacing: 8) {
                Text("이메일").font(.pretendMedium14).foregroundStyle(Color("gray-900"))
                TextField("", text: $email)
                    .padding(.horizontal, 16)
                    .frame(height: 48)
                    .background(Color("gray-50"))
                    .cornerRadius(8)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호").font(.pretendMedium14).foregroundStyle(Color("gray-900"))

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

                        if isPasswordEdited && !isPasswordValid {
                            Text("영문, 숫자, 특수기호를 모두 포함하여 입력해주세요.  (8글자 이상)")
                                .font(.pretendRegular12).foregroundStyle(.red)
                        }
                        if isPasswordEdited && !isConfirmMatched {
                            Text("비밀번호가 일치하지 않습니다.")
                                .font(.pretendRegular12).foregroundStyle(.red)
                        }

                        Button {
                            viewModel.changePassword(current: password, new: confirmPassword) {
                                isEditingPassword = false
                                password = ""
                                confirmPassword = ""
                                isPasswordEdited = false
                            }
                        } label: {
                            if viewModel.isUpdatingPassword {
                                ProgressView().frame(height: 48)
                            } else {
                                Text("비밀번호 변경")
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity, minHeight: 48)
                            }
                        }
                        .background(Color("primary-light"))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                        .disabled(!(isPasswordValid && isConfirmMatched))

                        Button("비밀번호 변경 취소") {
                            isEditingPassword = false
                            password = ""
                            confirmPassword = ""
                            isPasswordEdited = false
                        }
                        .font(.pretendMedium14)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color("primary-light"))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                    }
                } else {
                    Button("비밀번호 변경하기") { isEditingPassword = true }
                        .font(.pretendMedium14)
                        .frame(maxWidth: .infinity, minHeight: 48)
                        .background(Color("primary-light"))
                        .foregroundStyle(.black)
                        .cornerRadius(10)
                }
            }
        }
        .padding(20)
        .background(Color("gray-white"))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var deleteRow: some View {
        HStack(spacing: 120) {
            Button("로그아웃") { userSession.clear() }
                .foregroundStyle(Color("gray-500"))

            Button("회원 탈퇴", role: .destructive) {
                viewModel.deleteAccount(hard: true) { ok in
                    if ok {
                        deleteResultMessage = "탈퇴가 완료되었습니다."
                        userSession.clear()
                        showLogin = true
                    } else {
                        deleteResultMessage = viewModel.deleteErrorMessage ?? "탈퇴 실패"
                    }
                    showDeleteResult = true
                }
            }
            .foregroundStyle(Color("gray-900"))
        }
        .font(.pretendMedium14)
        .padding(.horizontal, 50)
        .padding(.vertical, 15)
    }

    private var footer: some View {
        HStack(spacing: 12) {
            Button("취소") { dismiss() }
                .frame(maxWidth: .infinity, minHeight: 48)
                .background(Color("gray-white"))
                .foregroundStyle(.black)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color("gray-200"), lineWidth: 1))

            Button("저장") {
                onSaved?()
                dismiss()
            }
            .frame(maxWidth: .infinity, minHeight: 48)
            .background(Color.black)
            .foregroundStyle(.white)
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color("gray-white"))
    }

    // MARK: - Helpers

    private func handlePicked(_ item: PhotosPickerItem) {
        Task {
            // Data 로드
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                await MainActor.run { viewModel.toastMessage = "이미지를 불러오지 못했습니다." }
                return
            }

            // 미리보기
            if let ui = UIImage(data: data) {
                await MainActor.run { self.localPreview = ui }
            }

            // 업로드
            let rawName: String = item.itemIdentifier ?? "profile"
            let filename: String = rawName + ".jpg"
            viewModel.uploadProfileImage(data, filename: filename) {
                // 성공 시 서버 기준 최신 이미지로 동기화
                viewModel.fetchMyProfile { p in
                    if let url = p?.imageUrl {
                        self.imageUrl = bustCache(url)
                    }
                    self.localPreview = nil
                }
            }
        }
    }

    private func scheduleNicknameCheck(_ newValue: String) {
        nicknameDebounceTask?.cancel()
        nicknameDebounceTask = Task {
            try? await Task.sleep(nanoseconds: 400_000_000) // 0.4s
            await MainActor.run {
                // 현재 닉네임을 그대로 넘겨도 OK (본인 닉네임은 서버에서 중복 제외)
                viewModel.checkUsername(newValue, currentNickname: nickname)
            }
        }
    }
}
private func bustCache(_ url: String) -> String {
    let ts = Int(Date().timeIntervalSince1970)
    return url.contains("?") ? "\(url)&cb=\(ts)" : "\(url)?cb=\(ts)"
}


// 프리뷰용
#Preview {
    EditProfileView(profile: .init(userId: 1, email: "test@example.com", nickname: "데모", imageUrl: nil))
}

