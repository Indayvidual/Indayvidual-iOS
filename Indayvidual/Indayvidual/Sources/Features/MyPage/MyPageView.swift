//
//  MyPageView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct MyPageView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goToPasswordConfirmView = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color("gray-50").ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 헤더
                    HStack(spacing: 10) {
                        Button {
                            dismiss()
                        } label: {
                            Image("back-icon")
                        }
                        
                        Text("마이페이지")
                            .font(.pretendSemiBold18)
                            .foregroundStyle(Color("gray-900"))
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 13)
                    .frame(height: 26)
                    .background(Color("gray-white"))
                    
                    
                    // 프로필 카드
                    HStack(spacing: 16) {
                        Image("profile")
                            .resizable()
                            .frame(width: 62, height:62 )
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("인데비")
                                .font(.pretendSemiBold18)
                                .foregroundStyle(Color("gray-900"))
                            
                            
                            HStack(spacing: 2 ) {
                                Button {
                                    goToPasswordConfirmView = true
                                } label: {
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
                    .padding(.top, 14)
                    .padding(.bottom, 10)
                    .background(Color("gray-white"))
                    
                    Spacer().frame(height: 10)
                    
                    
                    VStack(spacing: 10){
                        // 카드 목록
                        VStack(spacing: 1) {
                            NavigationRow(icon: "doc.text", title: "위젯 설정") {}
                                .padding(.bottom, 0)
                            
                            Divider()
                                .padding(.horizontal, 20)
                                .background(Color("gray-100"))
                            
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
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            NavigationLink(destination: PasswordConfirmView(), isActive: $goToPasswordConfirmView) {
                EmptyView()
            }
        }
    }
}

#Preview {
    MyPageView()
}

