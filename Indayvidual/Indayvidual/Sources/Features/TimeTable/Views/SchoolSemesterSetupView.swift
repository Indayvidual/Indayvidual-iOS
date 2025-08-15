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
    @State private var selectedSemester: Semester? = nil
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
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("학교 설정")
                            .font(.pretendSemiBold18)
                        
                        SelectionBar(
                            title: selectedSchoolName ?? "소속 대학명을 검색 하세요",
                            isSelected: selectedSchoolName != nil,
                            iconName: "Group",
                            onTap: { showSchoolSearchPopup = true }
                        )
                    }
                    
                    Spacer().frame(height: 50)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text("학기 설정")
                            .font(.pretendSemiBold18)
                        
                        Spacer().frame(height: 15)
                        
                        GeometryReader { geometry in
                            SelectionBar(
                                title: selectedSemester?.rawValue ?? "학기 선택",
                                isSelected: selectedSemester != nil,
                                iconName: showSemesterPicker ? "dropup" : "dropdown",
                                onTap: { withAnimation { showSemesterPicker.toggle() } }
                            )
                            
                            .overlay(alignment: .top) {
                                if showSemesterPicker {
                                    SemesterPickerView(selectedSemester: $selectedSemester)
                                        .offset(y: geometry.size.height + 4)
                                }
                            }
                        }
                        .frame(height: 56)
                        
                    }
                    .zIndex(1)
                    
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
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
        .task {
                    self.selectedSchoolName = timetableVm.selectedSchoolName
                    self.selectedSchoolSeq = timetableVm.selectedSchoolSeq
                    self.selectedSemester = timetableVm.selectedSemester
                }
    }
}

struct SemesterPickerView: View {
    @Binding var selectedSemester: Semester?
    
    var body: some View {
        // Picker가 Semester 타입을 직접 바인딩합니다.
        Picker("학기 선택", selection: $selectedSemester) {
            // ForEach는 Semester.allCases를 순회합니다.
            ForEach(Semester.allCases) { semester in
                Text(semester.rawValue).tag(semester as Semester?)
            }
        }
        .pickerStyle(.wheel)
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color(.gray50))
        .cornerRadius(10)
        .task {
            if selectedSemester == nil {
                selectedSemester = Semester.allCases.first
            }
        }
    }
}


#Preview {
    SchoolSemesterSetupView(timetableVm: TimetableViewModel())
}
