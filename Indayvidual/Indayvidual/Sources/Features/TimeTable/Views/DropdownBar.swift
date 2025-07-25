//
//  DropdownBar.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import SwiftUI

struct DropdownBar: View {
    var hint: String
    var options: [String]
    var cornerRadius: CGFloat = 4
    
    @Binding var selection: String?
    @State private var showOptions: Bool = false
    
    var body: some View{
        GeometryReader{
            let size = $0.size
            
            VStack(spacing: 0){
                HStack(spacing: 0){
                    Spacer().frame(width: 12)
                    
                    Text(selection ?? hint)
                        .font(.pretendRegular13)
                        .foregroundStyle(selection == nil ? Color(.gray500) : Color(.gray900))
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Image("mingcute_down-fill")
                        .rotationEffect(.init(degrees: showOptions ? -180 : 0)) /// 아이콘 선택시 회전하는 효과
                } 
            }
            .frame(width: size.width, height: size.height)
            .background(Color.white)
            .contentShape(.rect)
            .onTapGesture {
                withAnimation(.snappy){
                    showOptions.toggle()
                }
            }
            
            if showOptions{
                OptionsView()
                    .frame(width: size.width)
                    .background(Color.white)
                    .offset(y: size.height + 3)
            }
        }
        .frame(width: .infinity, height: 28)
    }
    
    @ViewBuilder
    func OptionsView() -> some View{
        VStack(spacing: 10){
            ForEach(options, id: \.self){ option in
                HStack(spacing: 0){
                    Spacer().frame(width: 12)
                    
                    Text(option)
                        .font(.pretendRegular13)
                        .foregroundStyle(Color(.gray900))
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
                    Image("mingcute_left-fill") /// 임시 이미지 추후 변경 예정
                        .opacity(selection == option ? 1 : 0)
                }
                .foregroundStyle(selection == option ? Color(.gray500) : Color(.gray900))
                .animation(.none, value: selection)
                .frame(height: 28)
                .contentShape(.rect)
                .onTapGesture {
                    withAnimation(.snappy){
                        selection = option
                        showOptions = false
                    }
                }
            }
        }
    }
}

