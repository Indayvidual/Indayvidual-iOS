//
//  ColorPickerSheetView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/29/25.
//

import SwiftUI

struct ColorPickerSheetView: View {
    @StateObject private var colorVm = ColorViewModel()
    @Environment(\.dismiss) private var dismiss
    @Binding var showColorPickerSheet: Bool
    @Binding var selectedColor: Color

    var body: some View{
        CustomActionSheet(
            title: "색상 선택",
            titleIcon: "ic_color_lens_48px",
            primaryButtonTitle: "선택 완료",
            secondaryButtonTitle: "초기화",
            primaryAction: {
                if let selected = colorVm.colors.first(where: { $0.isSelected }) {
                    selectedColor = Color(selected.name)
                }
                dismiss()
            },
            secondaryAction: {
                colorVm.resetToDefault()
            },
            primaryButtonColor: .gray900,
            primaryButtonTextColor: .white,
            secondaryButtonColor: .white,
            secondaryButtonTextColor: .black,
            secondaryButtonBorderColor: .gray200,
            buttonHeight: 55
        ) {
            VStack(alignment: .center, spacing: 0) {
                ColorGridView(viewModel: colorVm)
            }
        }
        
    }
}

#Preview {
    ColorPickerSheetView(
        showColorPickerSheet: .constant(true),
        selectedColor: .constant(.pink01) 
    )
}
