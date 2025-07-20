//
//  RecordView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/18/25.
//

import SwiftUI

struct RecordView: View {
    @Environment(\.dismiss) private var dismiss
    var sharedVM: CustomViewModel //CustomViewModel을 상위에서 뷰에서 불러와서 사용
    
    var body: some View {
        NavigationStack {
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
    }
    
    //사용자 이름 및 총 메모 갯수 출력
    var nameAndnum: some View {
        Group {
            HStack {
                Text("\(sharedVM.name)님의 기록")
                    .font(.pretendBold24)
                    .foregroundStyle(.black)
                Spacer()
            }
            
            Text("총 \(sharedVM.num)개")
                .font(.pretendSemiBold18)
                .foregroundStyle(.black)
            
            //메모가 하나도 없을 경우
            if sharedVM.num == 0 {
                Image(.noData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                memos
            }
        }
        .padding(.horizontal)
    }
    
    // 모든 메모를 리스트 형식으로 출력 뷰모델 추가 이후 네비게이션으로 내용 확인 및 수정할 수 있도록 변경 예정
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
