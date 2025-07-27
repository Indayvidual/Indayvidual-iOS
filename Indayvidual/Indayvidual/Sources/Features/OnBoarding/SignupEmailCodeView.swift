//
//  SignupEmailCodeView.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct SignupEmailCodeView: View {
    @State private var code: String = ""
    @State private var isCodeValid: Bool = false
    @State private var countdown: Int = 180
    @State private var timer: Timer? = nil
    @FocusState private var isCodeFocused: Bool

    var body: some View {
        VStack(spacing: 28) {
            // 뒤로가기
            HStack {
                Button {
                    // TODO: 뒤로가기 동작
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundStyle(.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)

            // 타이틀
            Text("메일로 전송된\n인증번호를 입력해주세요")
                .font(.pretendBold24)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
                .padding(.horizontal, 20)

            // 인증번호 입력
            VStack(spacing: 8) {
                Text("인증번호")
                    .font(.pretendMedium13)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 8) {
                    ZStack(alignment: .trailing) {
                        TextField("1234", text: $code)
                            .keyboardType(.numberPad)
                            .padding(.horizontal, 12)
                            .frame(height: 48)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .font(.system(size: 16))
                            .focused($isCodeFocused)
                            .onChange(of: code) { _ in validateCode() }

                        if countdown > 0 {
                            Text("\(countdown / 60):\(String(format: "%02d", countdown % 60))")
                                .font(.system(size: 14))
                                .foregroundStyle(Color("secondary"))
                                .padding(.trailing, 12)
                        }
                    }

                    Button {
                        countdown = 180
                        startTimer()
                    } label: {
                        Text("재전송")
                            .font(.system(size: 14, weight: .semibold))
                            .frame(width: 96, height: 48)
                            .background(Color.gray.opacity(0.2))
                            .foregroundStyle(.black)
                            .cornerRadius(8)
                    }
                    .disabled(countdown > 0)
                }
            }
            .padding(.horizontal, 20)

            Spacer()

            // 하단 버튼
            VStack {
                Button {
                    // 다음 단계
                } label: {
                    Text("다음")
                        .font(.pretendSemiBold15)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isCodeValid ? Color.black : Color.gray.opacity(0.3))
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
                .disabled(!isCodeValid)
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: -1)

        }
        
        .padding(.bottom, isCodeFocused ? 300 : 0)
        .animation(.easeOut(duration: 0.25), value: isCodeFocused)
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if countdown > 0 {
                countdown -= 1
            }
        }
    }

    private func validateCode() {
        isCodeValid = code.count == 4
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct SignupEmailCodeView_Previews: PreviewProvider {
    static var previews: some View {
        SignupEmailCodeView()
    }
}

