//
//  HideVIewController.swift
//  Indayvidual
//
//  Created by 김도연 on 8/19/25.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}
