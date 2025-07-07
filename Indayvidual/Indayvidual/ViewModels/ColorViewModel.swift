//
//  ColorViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/7/25.
//

import SwiftUI

class ColorViewModel: ObservableObject {
    @Published var colors: [ColorModel] = [
        ColorModel(name: "purple04"),
        ColorModel(name: "purple03"),
        ColorModel(name: "purple02"),
        ColorModel(name: "purple01"),
        ColorModel(name: "purple00"),
        ColorModel(name: "pink04"),
        ColorModel(name: "pink03"),
        ColorModel(name: "pink02"),
        ColorModel(name: "pink01"),
        ColorModel(name: "pink00"),
        ColorModel(name: "red04"),
        ColorModel(name: "red03"),
        ColorModel(name: "red02"),
        ColorModel(name: "red01"),
        ColorModel(name: "red00"),
        ColorModel(name: "yellow04"),
        ColorModel(name: "yellow03"),
        ColorModel(name: "yellow02"),
        ColorModel(name: "yellow01"),
        ColorModel(name: "yellow00"),
        ColorModel(name: "green04"),
        ColorModel(name: "green03"),
        ColorModel(name: "green02"),
        ColorModel(name: "green01"),
        ColorModel(name: "green00"),
        ColorModel(name: "turquoise04"),
        ColorModel(name: "turquoise03"),
        ColorModel(name: "turquoise02"),
        ColorModel(name: "turquoise01"),
        ColorModel(name: "turquoise00"),
        ColorModel(name: "blue04"),
        ColorModel(name: "blue03"),
        ColorModel(name: "blue02"),
        ColorModel(name: "blue01"),
        ColorModel(name: "blue00"),
        ColorModel(name: "gray04"),
        ColorModel(name: "gray03"),
        ColorModel(name: "gray02"),
        ColorModel(name: "gray01"),
        ColorModel(name: "gray00"),
    ]

    func colorSelection(for id: UUID) {
        for i in colors.indices {
                colors[i].isSelected = (colors[i].id == id)
            }
    }
}
