//
//  ColorViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/7/25.
//

import SwiftUI

class ColorViewModel: ObservableObject {
    @Published var colors: [ColorModel]

    init() {
        self.colors = [
            ColorModel(name: "purple-05", isSelected: true),  // 기본 값(임시로 지정했고, 추후 디자인 확정 되면 수정할 계획입니다)
            ColorModel(name: "purple-04"),
            ColorModel(name: "purple-03"),
            ColorModel(name: "purple-02"),
            ColorModel(name: "purple-01"),
            ColorModel(name: "pink-05"),
            ColorModel(name: "pink-04"),
            ColorModel(name: "pink-03"),
            ColorModel(name: "pink-02"),
            ColorModel(name: "pink-01"),
            ColorModel(name: "peach-05"),
            ColorModel(name: "peach-04"),
            ColorModel(name: "peach-03"),
            ColorModel(name: "peach-02"),
            ColorModel(name: "peach-01"),
            ColorModel(name: "yellow-05"),
            ColorModel(name: "yellow-04"),
            ColorModel(name: "yellow-03"),
            ColorModel(name: "yellow-02"),
            ColorModel(name: "yellow-01"),
            ColorModel(name: "green-05"),
            ColorModel(name: "green-04"),
            ColorModel(name: "green-03"),
            ColorModel(name: "green-02"),
            ColorModel(name: "green-01"),
            ColorModel(name: "teal-05"),
            ColorModel(name: "teal-04"),
            ColorModel(name: "teal-03"),
            ColorModel(name: "teal-02"),
            ColorModel(name: "teal-01"),
            ColorModel(name: "ocean-05"),
            ColorModel(name: "ocean-04"),
            ColorModel(name: "ocean-03"),
            ColorModel(name: "ocean-02"),
            ColorModel(name: "ocean-01"),
            ColorModel(name: "gray-700"),
            ColorModel(name: "gray-500"),
            ColorModel(name: "gray-400"),
            ColorModel(name: "gray-200"),
            ColorModel(name: "gray-50"),
        ]
    }

    func colorSelection(for id: UUID) {
        for i in colors.indices {
            colors[i].isSelected = (colors[i].id == id)
        }
    }
}
