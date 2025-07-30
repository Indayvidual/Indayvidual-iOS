//
//  ColorButton.swift
//  Indayvidual
//
//  Created by 장주리 on 7/30/25.
//

import SwiftUI

struct ColorButton: View {
    @Binding var showColorPickerSheet: Bool
    @Binding var selectedColor: Color

    var body: some View {
        Button(action: {
            showColorPickerSheet = true
        }) {
            Text("color")
                .font(.pretendRegular13)
                .foregroundStyle(Color.white)
                .frame(width: 52, height: 22)
                .background(selectedColor)
                .cornerRadius(3)
        }
    }
}
