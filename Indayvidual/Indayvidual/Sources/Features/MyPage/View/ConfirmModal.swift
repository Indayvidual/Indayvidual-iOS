//
//  ConfirmModal.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 8/19/25.
//

import SwiftUI

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
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Text(title)
                        .font(.pretendSemiBold16)
                        .foregroundStyle(Color("gray-900"))
                        .multilineTextAlignment(.center)

                    if let message {
                        Text(message)
                            .font(.pretendRegular13)
                            .foregroundStyle(Color("gray-900"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 6)
                    }
                }

                HStack(spacing: 12) {
                    Button("취소", action: onCancel)
                        .font(.pretendSemiBold14)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color("gray-white"))
                        .foregroundStyle(Color("gray-900"))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color("gray-200"), lineWidth: 1))
                        .cornerRadius(10)

                    Button(confirmText, action: onConfirm)
                        .font(.pretendSemiBold14)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(confirmStyle == .destructive ? Color.red : Color.black)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                }
            }
            .padding(20)
            .padding(.top, 10)
            .frame(maxWidth: 300)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .transition(.opacity)
    }
}
