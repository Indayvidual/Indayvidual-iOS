//
//  EditProfileView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var goToMyPage = false

    @State private var nickname: String = "인데비"
    @State private var email: String = "bbangitnow@gmail.com"
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEditingPassword: Bool = false

    @FocusState private var focusedField: Field?
    @State private var isPasswordEdited = false

    enum Field {
        case password
        case confirmPassword
    }

    var isPasswordValid: Bool {
        let regex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?\":{}|<>]).{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }

    var isConfirmMatched: Bool {
        return password == confirmPassword && !confirmPassword.isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("gray-50").ignoresSafeArea()

            VStack(spacing: 0) {
                // 헤더
                HStack(spacing: 10) {
                    Button {
                        dismiss()
                    } label: {
                        Image("back-icon")
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
                                Image("profile")
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .clipShape(Circle())
                                
                                Text("인데이비주얼에서 사용할 프로필 사진을 등록해주세요.")
                                    .font(.pretendSemiBold13)
                                    .foregroundStyle(Color("gray-900"))
                                
                                HStack(spacing: 8) {
                                    Button("기본 이미지로 변경") {}
                                        .font(.pretendMedium14)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .foregroundStyle(Color("gray-900"))
                                        .background(alignment: .center) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color("gray-200"), lineWidth: 1)
                                        }
                                    
                                    Button("이미지 변경") {}
                                        .font(.pretendMedium14)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 40)
                                        .foregroundStyle(Color("gray-900"))
                                        .background(alignment: .center) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color("gray-200"), lineWidth: 1)
                                        }
                                    
                                }
                            }
                            
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
                                    
                                    Button("변경하기") {}
                                        .font(.pretendMedium14)
                                        .padding(.horizontal, 24)
                                        .frame(height: 48)
                                        .background(Color("primary-light"))
                                        .foregroundStyle(.black)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color("gray-white"))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                        // 회원 정보 카드
                        VStack(alignment: .leading, spacing: 24) {
                            Text("회원 정보")
                                .font(.pretendSemiBold16)

                            VStack(alignment: .leading, spacing: 8) {
                                Text("이메일")
                                    .font(.pretendMedium14)
                                    .foregroundStyle(Color("gray-900"))

                                TextField("", text: $email)
                                    .padding(.horizontal, 16)
                                    .frame(height: 48)
                                    .background(Color("gray-50"))
                                    .cornerRadius(8)
                            }

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
                                        .onTapGesture {
                                            isPasswordEdited = true
                                        }

                                        CustomTextField(
                                            placeholder: "새 비밀번호 확인",
                                            text: $confirmPassword,
                                            isSecure: true,
                                            isError: isPasswordEdited && !isConfirmMatched,
                                            errorMessage: "비밀번호가 일치하지 않습니다.",
                                            showToggleSecure: true
                                        )
                                        .focused($focusedField, equals: .confirmPassword)
                                        .onTapGesture {
                                            isPasswordEdited = true
                                        }
                                    }

                                    Button("비밀번호 변경 취소") {
                                        isEditingPassword = false
                                        password = ""
                                        confirmPassword = ""
                                    }
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 48)
                                    .background(Color("primary-light"))
                                    .foregroundStyle(.black)
                                    .cornerRadius(10)

                                } else {
                                    Button("비밀번호 변경하기") {
                                        isEditingPassword = true
                                    }
                                    .font(.pretendMedium14)
                                    .frame(maxWidth: .infinity)
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

                        // 하단 로그아웃 / 회원탈퇴
                        HStack(spacing: 120 ) {
                            Button("로그아웃") {}
                                .foregroundStyle(Color("gray-500"))
                            Button("회원탈퇴") {}
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
                    Button("취소") {}
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color("gray-white"))
                        .foregroundStyle(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("gray-200"), lineWidth: 1)
                        )
                    
                    Button("저장") {
                        goToMyPage = true                   }
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                            .background(Color.black)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(Color("gray-white"))
                
                NavigationLink(destination: MyPageView(), isActive: $goToMyPage) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    EditProfileView()
}
