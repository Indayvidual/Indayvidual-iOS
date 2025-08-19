//
//  MyPageView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

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

    // 편집 완료 토스트
    var showEditToast: Bool = false
    @State private var showToast = false

    var body: some View {
        ZStack {
            NavigationStack(path: $path) {
                VStack(spacing: 0) {
                    header
                    profileCard
                    Spacer().frame(height: 10)
                    menuCards
                    Spacer()
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
                        // 저장하면 마이페이지로 복귀 + 토스트 3초 노출
                        EditProfileView(profile: profile) {
                            viewModel.refreshIfReauthValid(session: userSession)
                            path.removeAll() // 루트(MyPage)로 복귀
                            withAnimation { showToast = true }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                withAnimation { showToast = false }
                            }
                        }
                    }
                }
            }
            .overlay(loadingOverlay)

            // 편집 완료 토스트
            if showToast {
                EditDoneToast()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onAppear {
            viewModel.preload(from: userSession)
            viewModel.refreshIfReauthValid(session: userSession)

            // 외부에서 true로 주입되면 자동 표시
            if showEditToast {
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation { showToast = false }
                }
            }
        }
        .task { viewModel.refreshIfReauthValid(session: userSession) }
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

// MARK: - 편집 완료 토스트 뷰 (디자인 유사)
private struct EditDoneToast: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .imageScale(.large)
                .foregroundStyle(Color("primary-light")) // 필요 시 시스템 그린으로: .green
            Text("회원정보가 수정되었습니다.")
                .font(.pretendMedium14)
                .foregroundStyle(Color.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview { MyPageView() }
