//
//  SemesterSelectionSheet.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//
import SwiftUI

struct SemesterSelectionSheet: View {
    @Binding var isPresented: Bool
    @Binding var selectedSemester: String?

    @State private var selectedIndex = 0

    private let semesters = (1...4).flatMap { year in
        (1...2).map { semester in
            "\(year)학년 \(semester)학기"
        }
    }

    init(isPresented: Binding<Bool>, selectedSemester: Binding<String?>) {
        self._isPresented = isPresented
        self._selectedSemester = selectedSemester
    }

    var body: some View {
        CustomActionSheet(
            title: "학기 설정",
            primaryButtonTitle: "학기 설정 완료",
            primaryAction: {
                selectedSemester = semesters[selectedIndex]
                isPresented = false
            },
            secondaryAction: {
                isPresented = false
            }
        ) {
            Spacer().frame(height: 24)
            VStack(alignment: .leading, spacing: 0) {
                Picker("학기 선택", selection: $selectedIndex) {
                    ForEach(semesters.indices, id: \.self) { index in
                        Text(semesters[index]).tag(index)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 150)
                .clipped()
                
                Spacer()
            }
        }
    }
}

struct SemesterSelectionSheet_Previews: PreviewProvider {
    @State static var isPresented = true
    @State static var selectedSemester: String? = nil

    static var previews: some View {
        SemesterSelectionSheet(
            isPresented: $isPresented,
            selectedSemester: $selectedSemester
        )
    }
}
