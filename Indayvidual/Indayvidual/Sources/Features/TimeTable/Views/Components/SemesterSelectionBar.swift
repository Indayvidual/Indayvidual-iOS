//
//  SelectionRow.swift
//  Indayvidual
//
//  Created by 장주리 on 8/13/25.
//


import SwiftUI

struct SemesterSelectionBar: View {
    @Binding var selection: String?
    @State private var showOptions = false
    var options: [String] = Semester.allCases.map { $0.rawValue }
    
    var body: some View {
        // 버튼 뷰를 기준으로 드롭다운의 위치가 결정
        let buttonView = HStack {
            Spacer()
            Text(selection ?? "학기 선택")
                .font(.pretendRegular13)
                .foregroundColor(selection == nil ? .gray : Color(.gray900))
            Spacer()
            
            Image("mingcute_down-fill")
                .rotationEffect(.degrees(showOptions ? -180 : 0))
        }
            .padding(.horizontal, 5)
            .frame(width: 108, height: 28)
            .background(Color.white)
            .cornerRadius(4)
            .contentShape(Rectangle()) // 전체 영역이 탭 되도록 설정
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    showOptions.toggle()
                }
            }
        
        // 버튼 뷰에 overlay를 사용하여 드롭다운 메뉴를 띄웁니다.
        buttonView
            .overlay(alignment: .topLeading) { // 드롭다운을 버튼의 좌측 상단에 정렬
                if showOptions {
                    dropdownList
                    // 버튼 높이(28) + 4 만큼 y축으로 이동
                        .offset(y: 28 + 4)
                }
            }
            .zIndex(100)
        
    }
    
    private var dropdownList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(options.indices, id: \.self) { index in
                    if index != 0 {
                        Divider()
                            .padding(.trailing, 13)
                    }
                    
                    Text(options[index])
                        .font(.pretendRegular13)
                        .background(selection == options[index] ? Color.gray.opacity(0.1) : Color.clear)
                        .contentShape(Rectangle())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 7)
                        .onTapGesture {
                            selection = options[index]
                            withAnimation(.easeInOut(duration: 0.2)) {
                                showOptions = false
                            }
                        }
                }
            }
            .padding(.horizontal, 18)
        }
        .frame(width: 108, height: 95)
        .background(Color.white)
        .cornerRadius(4)
    }
}

#Preview {
    SemesterSelectionBar(
        selection: .constant(nil)
    )
}
