//
//  RecordView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    var sharedVM: CustomViewModel
    
    var body: some View {
        ZStack {
            Color.gray50
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                nameAndnum
                
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                    }
                }
            }
        }
        .tint(.black)
    }
    
    var nameAndnum: some View {
        Group {
            HStack {
                Text("\(sharedVM.name)님의 기록")
                    .font(.pretendBold24)
                Spacer()
            }
            
            Text("총 \(sharedVM.num)개")
                .font(.pretendSemiBold18)
            
            if sharedVM.num == 0 {
                Spacer()
                Image(.noData)
                Spacer()
            } else {
                memos
            }
        }
        .padding(.horizontal)
    }
    
    var memos: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(height: 512)
            
            List {
                ForEach(Array(sharedVM.memos.enumerated()), id: \.element.id) { index, memo in
                    VStack(spacing: 12) {
                        HStack {
                            Text(memo.title)
                                .font(.pretendSemiBold22)
                            Spacer()
                            Text(memo.date)
                                .font(.pretendMedium14)
                                .foregroundStyle(.gray400)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .foregroundStyle(.gray50)
                                )
                        }
                    }
                    .padding(.vertical, 8)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            sharedVM.deleteMemo(at: index)
                        } label: {
                            Label("삭제", systemImage: "trash")
                                .tint(.red)
                        }
                    }
                }
                .listRowBackground(Color.white) // ✅ 배경 흰색
            }
            .listStyle(.plain)
            .frame(height: 512)
            .scrollContentBackground(.hidden)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

#Preview {
    RecordView(sharedVM: CustomViewModel.init())
}
