//
//  RecordView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var Add : Bool = false
    var sharedVM: CustomViewModel // 공유된 ViewModel로 상위 뷰에서 가져와 사용
    
    var body: some View {
        ZStack {
            Color.gray50
                .ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 20) {
                nameAndnum
                
            }
        }
        .floatingBtn {
            Add = true
        }
        .navigationDestination(isPresented: $Add) {
            AddMemoView(
                vm: MemoViewModel(sharedVM: sharedVM)
            )
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
    
    //사용자 이름 및 총 메모 갯수 출력
    var nameAndnum: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(sharedVM.name)님의 기록")
                    .font(.pretendBold24)
                    .foregroundStyle(.black)
                Spacer()
            }
            
            Text("총 \(sharedVM.memosCount)개")
                .font(.pretendSemiBold18)
                .foregroundStyle(.black)
            
            //메모가 하나도 없을 경우
            if sharedVM.memos.isEmpty {
                Image(.noData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .frame(height: 512)
            } else {
                memos
            }
        }
        .padding(.horizontal)
    }
    
    // 모든 메모 리스트 형식으로 출력
    var memos: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .frame(height: 512)
            List {
                ForEach(Array(sharedVM.memos.enumerated()), id: \.element.id) { index, memo in
                    NavigationLink {
                        AddMemoView(
                            vm: MemoViewModel(
                                sharedVM: sharedVM,
                                memo: memo,
                                index: index
                            )
                        )
                    } label: {
                        VStack(spacing: 12) {
                            HStack {
                                Text(memo.title)
                                    .font(.pretendSemiBold22)
                                    .foregroundStyle(.black)
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
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            sharedVM.deleteMemo(at: index)
                        } label: {
                            Label("삭제", systemImage: "trash")
                                .tint(.red)
                        }
                    }
                }
                .listRowBackground(Color.white)
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
