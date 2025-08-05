//
//  AddMemoView.swift
//  Indayvidual
//
//  Created by 김도연 on 7/20/25.
//

import SwiftUI

struct AddMemoView: View {
    @Environment(\.dismiss) private var dismiss
    @State var vm: MemoViewModel
    
    var body: some View {
        ZStack {
            Color.gray50.ignoresSafeArea()
            VStack(spacing: 12) {
                // 제목 입력
                TextField("새로운 메모", text: $vm.title)
                    .font(.pretendMedium14)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                
                // 본문 입력
                TextEditor(text: $vm.content)
                    .font(.pretendRegular15)
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading, content: {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
                .font(.pretendSemiBold18)
                .tint(.black)
            })
            ToolbarItem(placement: .principal, content: {
                Text(vm.isEditing ? "메모 수정" : "새로운 메모")
                    .font(.pretendSemiBold18)
                    .tint(.black)
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button(vm.isEditing ? "수정" : "등록") {
                    vm.save()
                    dismiss()
                }
                .font(.pretendSemiBold18)
                .tint(.black)
            })
        }
    }
}

#Preview {
    // 신규 메모
    NavigationStack {
        AddMemoView(vm: MemoViewModel(sharedVM: CustomViewModel()))
    }
}

#Preview {
    // 수정 예시
    let customVM = CustomViewModel()
    customVM.memos.append(
        MemoModel(
            title: "샘플 메모",
            content: "내용",
            date: "250719",
            time: "12:00"
        )
    )
    return AddMemoView(
        vm: MemoViewModel(
            sharedVM: customVM,
            memo: customVM.memos[0],
            index: 0
        )
    )

}
