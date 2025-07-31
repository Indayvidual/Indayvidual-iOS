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
                    
                    Text(selectionFormatted(selection) ?? hint)
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
        .frame(width: 240, height: 28)
    }
    
    /// 기존 문자열에서 "학교"와 "학년"과 "학기" 부분을 찾아 "학교명 학년-학기" 형태로 변환해주는 함수
    func selectionFormatted(_ selection: String?) -> String? {
        guard let selection = selection else { return nil }
        
        // 예: "동국대학교 4학년 1학기"
        // 정규식으로 학교 이름과 학년, 학기 분리
        // 학교 이름: 앞부분 문자열, 뒤에 "4학년 1학기" 형태
        
        // 학년, 학기 부분만 추출
        let pattern = #"(.+?)\s+(\d)학년\s*(\d)학기"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: selection, range: NSRange(selection.startIndex..., in: selection)) {
            
            if let schoolRange = Range(match.range(at: 1), in: selection),
               let yearRange = Range(match.range(at: 2), in: selection),
               let semesterRange = Range(match.range(at: 3), in: selection) {
                
                let school = selection[schoolRange]
                let year = selection[yearRange]
                let semester = selection[semesterRange]
                return "\(school) \(year)-\(semester)"
            }
        }
        
        return selection
    }

    
    @ViewBuilder
    func OptionsView() -> some View{
        VStack(spacing: 10){
            ForEach(options, id: \.self){ option in
                HStack(spacing: 0){
                    Spacer().frame(width: 12)
                    
                    Text(selectionFormatted(selection) ?? hint)
                        .font(.pretendRegular13)
                        .foregroundStyle(Color(.gray900))
                        .lineLimit(1)
                    
                    Spacer(minLength: 0)
                    
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

