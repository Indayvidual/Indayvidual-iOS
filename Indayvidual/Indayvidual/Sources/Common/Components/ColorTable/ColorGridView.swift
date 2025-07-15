//
//  ColorGridView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/7/25.
//

import SwiftUI

struct ColorGridView: View {
    @ObservedObject var viewModel: ColorViewModel

    let columns = Array(repeating: GridItem(.flexible(), spacing: 31.51), count: 5)

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(viewModel.colors) { colorItem in
                Color(colorItem.name)
                    .frame(width: 39.39, height: 39.39)
                    .clipShape(Circle())
                    .overlay(
                            Group {
                                if colorItem.isSelected {
                                    Image("check-icon")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 20, height: 13)
                                }
                            }
                        )
                    .onTapGesture {
                        viewModel.colorSelection(for: colorItem.id)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
    }
   

}

#Preview {
    ColorGridView(viewModel: ColorViewModel())
}
