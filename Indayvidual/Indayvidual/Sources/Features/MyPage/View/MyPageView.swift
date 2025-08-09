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

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 0) {
                header
                profileCard
                Spacer().frame(height: 10)
                menuCards
            }
            .background(Color("gray-50").ignoresSafeArea())
            .navigationDestination(for: SettingsRoute.self) { route in
                switch route {
                case .passwordConfirm:
                    PasswordConfirmView { profile in
                        path.append(.profileEdit(profile))
                    }
                case .profileEdit(let profile):
                    EditProfileView(profile: profile) {
                        viewModel.refreshIfReauthValid()
                    }
                }
            }
        }
        .task { viewModel.refreshIfReauthValid() }
        .overlay(loadingOverlay)
        .alert("프로필 로드 실패",
               isPresented: .constant(viewModel.loadErrorMessage != nil)) {
            Button("확인") { viewModel.loadErrorMessage = nil }
        } message: {
            Text(viewModel.loadErrorMessage ?? "")
        }
    }

    private var header: some View {
        HStack {
            Button { dismiss() } label: { Image("back-icon") }
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

            Spacer()

            HStack(spacing: 120) {
                Button("로그아웃") { userSession.clear() }
                    .foregroundStyle(Color("gray-500"))
            }
            .font(.pretendMedium14)
            .padding(.horizontal, 50)
            .padding(.vertical, 15)
        }
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
