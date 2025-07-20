//
//  MemoView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI

struct MemoView: View {
    var memo = MemoModel(
        title: "메모1",
        content: "테스트 내용입니다",
        date: "250719",
        time: "12:34"
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(.custom)
                .renderingMode(.template)
                .foregroundStyle(.black)
            Text(memo.title)
                .font(.pretendSemiBold22)
                .foregroundStyle(.black)
                .lineLimit(1)
                .frame(width: 132, height: 28, alignment: .leading)
            Text(memo.content)
                .font(.pretendSemiBold17)
                .foregroundStyle(.gray500)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(width: 132, height: 48, alignment: .leading)
            
            HStack(spacing: 20) {
                Text(memo.date)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 60, height: 20)
                            .foregroundStyle(.gray50)
                    )
                
                Text(memo.time)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 48, height: 20)
                            .foregroundStyle(.gray50)
                    )
            }
            .font(.pretendMedium14)
            .foregroundStyle(.gray)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 160, height: 180)
                .foregroundStyle(.white)
        )
    }
}

#Preview {
    ZStack {
        Color.gray
        MemoView(memo: MemoModel(
                title: "새로운 메모",
                content: "이건 매우 길어질 수 있는 테스트용 메모 내용입니다. 아마도 줄바꿈 없이 계속 길어질 수 있어요. 그러니까 잘라줘야 해요!",
                date: "250719",
                time: "12:34"
            ))
    }
}
