//
//  MemoView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI

struct MemoView: View {
    @Bindable var vm: MemoViewModel
    
    init() {
        self.vm = .init()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(.custom)
                .renderingMode(.template)
                .tint(.black)
            Text("메모\(vm.number)")
                .font(.pretendSemiBold22)
            Text(vm.memoContent)
                .font(.pretendSemiBold17)
                .foregroundStyle(.gray500)
            
            HStack {
                Text(vm.date)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 52, height: 20)
                            .foregroundStyle(.gray50)
                    )
                Text(vm.time)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 40, height: 20)
                            .foregroundStyle(.gray50)
                    )
            }
            .font(.pretendMedium14)
            .foregroundStyle(.gray)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 172, height: 200)
                .foregroundStyle(.white)
        )
    }
}

#Preview {
    MemoView()
}
