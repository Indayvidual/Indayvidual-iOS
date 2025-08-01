//
//  NavigationRow.swift
//  Indayvidual
//
//  Created by Jung Hyun Han on 7/27/25.
//

import SwiftUI

struct NavigationRow: View {
    var icon: String
    var title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(Color("gray-900"))

                Text(title)
                    .font(.pretendSemiBold15)
                    .foregroundStyle(Color("gray-900"))

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(Color("gray-900"))
            }
            .padding(20)
            .padding(.vertical, 10)
            .background(Color("gray-white"))
        }
    }
}
