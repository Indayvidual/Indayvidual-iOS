//
//  MyPageView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

private enum SettingsRoute: Hashable {
    case passwordConfirm
    case profileEdit(Profile)
}

struct MyPageView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var userSession: UserSession
    @StateObject private var viewModel = MyPageViewModel()
    @State private var path: [SettingsRoute] = []

    // 탈퇴 관련 상태
    @State private var showDeleteConfirm = false
    @State private var showDeleteResult = false
    @State private var deleteResultMessage: String = ""

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                profileCard
                Spacer().frame(height: 10)
                menuCards
//                deleteCard
            }
            .background(Color("gray-50"))
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .passwordConfirm:
                    PasswordConfirmView { profile in
                        path.append(.profileEdit(profile))
                    } onKakaoVerified: { profile in
                        path.append(.profileEdit(profile))
                    }

                case .profileEdit(let profile):
                    EditProfileView(profile: profile) {
                        viewModel.refreshIfReauthValid(session: userSession)
                    }
                }
            }
        }
        .onAppear {
            viewModel.preload(from: userSession)
            viewModel.refreshIfReauthValid(session: userSession)
        }
        .task { viewModel.refreshIfReauthValid(session: userSession) }
        .overlay(loadingOverlay)
        // 삭제 진행 로딩
        .overlay {
            if viewModel.isDeleting {
                ZStack {
                    Color.black.opacity(0.05).ignoresSafeArea()
                    ProgressView("탈퇴 진행 중…")
                        .padding(16)
                        .background(Color("gray-white"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        // 결과 알림
        .alert("알림", isPresented: $showDeleteResult) {
            Button("확인") { }
        } message: {
            Text(deleteResultMessage)
        }
        // 확인 알럿
        .alert("정말 탈퇴하시겠어요?", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) { }
//            Button("탈퇴", role: .destructive) { performDelete(hard: false) }
        } message: {
            Text("기본은 소프트 삭제입니다. 필요 시 하드 삭제로 변경할 수 있어요.")
        }
        // 프로필 로드 실패 알럿
        .alert("프로필 로드 실패",
               isPresented: .constant(viewModel.loadErrorMessage != nil)) {
            Button("확인") { viewModel.loadErrorMessage = nil }
        } message: {
            Text(viewModel.loadErrorMessage ?? "")
        }
    }

    // MARK: - Views

    private var header: some View {
        HStack {
            Button { dismiss() } label: { Image(systemName: "chevron.left") }
            Text("마이페이지")
                .font(.pretendSemiBold18)
                .foregroundStyle(Color("gray-900"))
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 13)
        .background(Color("gray-white"))
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            profileImage
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.nickname.isEmpty ? "닉네임 불러오는 중..." : viewModel.nickname)
                    .font(.pretendSemiBold18)
                    .foregroundStyle(Color("gray-900"))
                HStack(spacing: 2) {
                    Button { path.append(.passwordConfirm) } label: {
                        Text("내 정보 수정")
                            .font(.pretendMedium14)
                            .foregroundStyle(Color("gray-500"))
                    }
                    Image("right-arrow")
                }
            }
            Spacer()
//            Button("로그아웃") { userSession.clear() }
        }
        .padding(20)
        .background(Color("gray-white"))
    }

    private var profileImage: some View {
        Group {
            if let urlStr = viewModel.imageUrl, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView().frame(width: 62, height: 62)
                    case .success(let img):
                        img.resizable().frame(width: 62, height: 62).clipShape(Circle())
                    default:
                        Image("profile").resizable().frame(width: 62, height: 62).clipShape(Circle())
                    }
                }
            } else {
                Image("profile").resizable().frame(width: 62, height: 62).clipShape(Circle())
            }
        }
    }

    private var menuCards: some View {
        VStack(spacing: 10) {
            VStack(spacing: 1) {
                NavigationRow(icon: "doc.text", title: "위젯 설정") {}
                Divider().padding(.horizontal, 20).background(Color("gray-100"))
                NavigationRow(icon: "bookmark", title: "구독 관리") {}
            }
            .background(Color("gray-white"))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 1) {
                NavigationRow(icon: "bubble.left", title: "인데이비주얼 팀에게 문의하기") {}
            }
            .background(Color("gray-white"))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
            Button("로그아웃") {
                        
                        userSession.clear()
                       
                    }
        }
        .padding(.horizontal, 20)
    }

    private var loadingOverlay: some View {
        Group {
            if viewModel.isLoading {
                ZStack {
                    Color.black.opacity(0.05).ignoresSafeArea()
                    ProgressView("불러오는 중…")
                        .padding(16)
                        .background(Color("gray-white"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }
}

#Preview { MyPageView() }
