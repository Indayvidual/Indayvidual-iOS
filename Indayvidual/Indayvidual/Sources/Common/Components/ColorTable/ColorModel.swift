//
//  ColorModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/7/25.
//

import SwiftUI

struct ColorModel: Identifiable {
    let id = UUID()
    let name: String         // 컬러 에셋 이름
    var isSelected: Bool = false
}
