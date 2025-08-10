//
//  SchoolSemesterSetupView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct SchoolSemesterSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedSchoolName: String? = nil
    @State private var selectedSchoolSeq: String? = nil
    @State private var showSemesterPicker = false
    @State private var selectedSemester: String? = nil
    @State private var showSchoolSearchPopup = false
    
    @ObservedObject var timetableVm: TimetableViewModel
    
    var onCompletion: ((String, String) -> Void)? = nil
    var onSetupTapped: (() -> Void)? = nil
    
    var body: some View {
        ZStack {
            CustomActionSheet(
                title: "학교/학기 설정",
                primaryButtonTitle: "저장",
                primaryAction: {
                    guard let schoolSeq = selectedSchoolSeq,
                          let schoolName = selectedSchoolName,
                          let semester = selectedSemester else { return }
                    
                    timetableVm.saveSchoolSemester(schoolSeq: schoolSeq, schoolName: schoolName, semester: semester)
                },
                secondaryAction: {
                    timetableVm.showSchoolSemesterSetup = false
                    timetableVm.isSchoolRegistered = false
                },
                primaryButtonColor: (selectedSchoolName != nil && selectedSemester != nil) ? .gray900 : .gray100,
                headerLeftButton: {
                    AnyView(
                        Button(action: { dismiss() }) {
                            Image(.back)
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                    )
                }
            ) {
                VStack {
                    Text("학교 설정")
                        .font(.pretendSemiBold18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer().frame(height: 15)
                    
                    SelectionBar(
                        title: selectedSchoolName ?? "소속 대학명을 검색 하세요",
                        isSelected: selectedSchoolName != nil,
                        iconName: "Group",
                        onTap: { showSchoolSearchPopup = true }
                    )
                    
                    Spacer().frame(height: 50)
                    
                    Text("학기 설정")
                        .font(.pretendSemiBold18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    SelectionBar(
                        title: selectedSemester ?? "학기 선택",
                        isSelected: selectedSemester != nil,
                        iconName: showSemesterPicker ? "dropup" : "dropdown",
                        onTap: {
                            withAnimation { showSemesterPicker.toggle() }
                        }
                    )
                                        
                    // 학기 선택 피커
                    if showSemesterPicker {
                        SemesterPickerView(selectedSemester: $selectedSemester)
                            .transition(.opacity)
                            .animation(.easeInOut, value: showSemesterPicker)
                        
                    }
                    
                }
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(12)
                .frame(height: 282)
                .frame(maxWidth: .infinity)
            }
            
            // 학교 검색 팝업
            if showSchoolSearchPopup {
                SchoolSearchPopup(
                    isPresented: $showSchoolSearchPopup,
                    selectedSchoolName: $selectedSchoolName,
                    selectedSchoolSeq: $selectedSchoolSeq
                )
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    struct SemesterPickerView: View {
        @Binding var selectedSemester: String?
        @State private var selectedIndex = 0
        
        private let semesters = (1...4).flatMap { year in
            (1...2).map { semester in
                "\(year)학년 \(semester)학기"
            }
        }
        
        var body: some View {
            Picker("학기 선택", selection: $selectedIndex) {
                ForEach(semesters.indices, id: \.self) { index in
                    Text(semesters[index]).tag(index)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(height: 150)
            .onChange(of: selectedIndex) {
                selectedSemester = semesters[selectedIndex]
            }
        }
    }
}
