//
//  SchoolSemesterSetupView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct SchoolSemesterSetupView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var showModal: Bool
    @State private var selectedSchoolName: String? = nil
    @State private var showSemesterPicker = false
    @State private var selectedSemester: String? = nil
    @State private var showSchoolSearchPopup = false
    
    @StateObject private var timetableVm = TimetableViewModel()
    
    var onCompletion: ((String, String) -> Void)?
    var onSetupTapped: (() -> Void)?
    
    var body: some View {
        ZStack { 
            CustomActionSheet(
                title: "학교/학기 설정",
                primaryButtonTitle: "저장",
                primaryAction: {
                    if let school = selectedSchoolName, let semester = selectedSemester {
                        onCompletion?(school, semester)
                        timetableVm.isSchoolRegistered = true
                        print(timetableVm.isSchoolRegistered)
                        dismiss()
                    }
                },
                secondaryAction: {
                    dismiss()
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
                ZStack{
                    RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.white))
                            .frame(height: 282)
                            .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("학교 설정")
                            .font(.pretendSemiBold18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Spacer().frame(height: 15)
                        
                        SelectionBar(
                            title: selectedSchoolName ?? "소속 대학명을 검색 하세요",
                            isSelected: selectedSchoolName != nil,
                            iconName: "Group",
                            onTap: {
                                showSchoolSearchPopup = true
                            }
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
                                withAnimation {
                                    showSemesterPicker.toggle()
                                }
                            }
                        )
                        
                        if showSemesterPicker {
                            SemesterPickerView(selectedSemester: $selectedSemester)
                                .transition(.opacity)
                                .animation(.easeInOut, value: showSemesterPicker)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .navigationBarBackButtonHidden(true)
                }
                
            }

            if showSchoolSearchPopup {
                SchoolSearchPopup(
                    isPresented: $showSchoolSearchPopup,
                    selectedSchoolName: $selectedSchoolName
                )
            }
            
        }
    }
    
    struct SemesterPickerView: View {
        @Binding var selectedSemester: String?
        @State private var selectedIndex = 0
        
        private let semesters = (1...4).flatMap { year in
            (1...2).map { semester in
                "\(year)학년   \(semester)학기"
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
            .clipped()
            .onChange(of: selectedIndex) {
                selectedSemester = semesters[selectedIndex]
            }
        }
    }
}

#Preview {
    SchoolSemesterSetupView(
        showModal: .constant(true),
        onCompletion: { school, semester in
            print("선택된 학교: \(school), 학기: \(semester)")
        },
        onSetupTapped: {
            print("학교 설정하기 버튼 탭됨")
        }
    )
}
