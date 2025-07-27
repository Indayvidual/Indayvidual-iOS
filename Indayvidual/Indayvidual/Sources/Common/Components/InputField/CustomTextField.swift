//
//  CustomTextField.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    var isError: Bool = false
    var errorMessage: String? = nil
    var showToggleSecure: Bool = false

    @State private var isPasswordVisible: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .trailing) {
                Group {
                    if isSecure && !isPasswordVisible {
                        SecureField(placeholder, text: $text)
                            .focused($isFocused)
                    } else {
                        TextField(placeholder, text: $text)
                            .focused($isFocused)
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isError ? Color.red : Color.gray.opacity(0.3), lineWidth: 1)
                )
                .font(.system(size: 14))

                if showToggleSecure && isSecure {
                    Button {
                        isPasswordVisible.toggle()
                    } label: {
                        Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .padding(.trailing, 12)
                    }
                }
            }

            if isError, let message = errorMessage {
                Text(message)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 4)
            }
        }
    }
}
