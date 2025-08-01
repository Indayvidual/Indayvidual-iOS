//
//  TimetableView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI
import PhotosUI

struct TimetableView: View {
    @StateObject private var timetableVm = TimetableViewModel()
    
    var body: some View {
        NavigationStack {
            mainContent
                .onAppear(perform: timetableVm.onAppear)
                .floatingBtn { timetableVm.showImagePicker = true }  // 플로팅 버튼 액션 처리
                .photosPicker(
                    isPresented: $timetableVm.showImagePicker,
                    selection: $timetableVm.selectedPhotoItem,
                    matching: .images
                )
                .background(Color(.gray50))
                .navigationDestination(isPresented: $timetableVm.navigateToSchoolSemesterRegistration) {
                    SchoolSemesterSetupView(
                        showModal: .constant(false),
                        onCompletion: { school, semester in
                            // 저장 후 팝업 닫고 등록 완료 상태 변경
                            timetableVm.isSchoolRegistered = true
                            timetableVm.showSchoolSetupOverlay = false
                            timetableVm.showSchoolRegistrationPopup = false
                            timetableVm.navigateToSchoolSemesterRegistration = false
                            
                            // 선택된 학교/학기 업데이트
                            timetableVm.updateSchoolSemester(schoolName: school, semester: semester)
                        }
                    )
                }
        }
        // 학교/학기 등록 팝업 오버레이
        .overlay {
            if timetableVm.showSchoolRegistrationPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { timetableVm.showSchoolRegistrationPopup = false }
                
                VStack {
                    Spacer()
                    SchoolSemesterSetupView(
                        showModal: $timetableVm.showSchoolRegistrationPopup,
                        onCompletion: timetableVm.handleSchoolRegistrationCompletion,
                        onSetupTapped: timetableVm.handleSchoolRegistrationSetupTap
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        // 학교 설정 오버레이 팝업
        .overlay {
            if timetableVm.showSchoolSetupOverlay {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { timetableVm.showSchoolSetupOverlay = false }
                
                VStack {
                    Spacer()
                    NoticePopupView(
                        showModal: $timetableVm.showSchoolSetupOverlay,
                        onCompletion: timetableVm.handleSchoolSetupCompletion,
                        onSetupTapped: timetableVm.handleSchoolSetupTapped
                    )
                    .frame(width: 315, height: 172)
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .transition(.opacity)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
    }
}

private extension TimetableView {
    // 메인 화면 구성 뷰
    var mainContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Topbar()  // 상단 바
            
            Spacer().frame(height: 10)
            
            DropdownBar(
                hint: "학교/학기 선택",
                options: timetableVm.dropdownOptions,  // 드롭다운 선택지
                selection: $timetableVm.selection       // 선택된 시간표
            )
            .padding(.horizontal, 15)
            .zIndex(1)
            
            Spacer().frame(height: 22)
            
            HStack {
                    Spacer()
                    timetableContent()
                    Spacer()
                }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // 시간표 이미지 혹은 빈 화면 처리
    @ViewBuilder
    func timetableContent() -> some View {
        if let image = timetableVm.selectedImage {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
        } else if timetableVm.timetableImages.isEmpty {
            EmptyTimeTableView()  // 시간표 없을 때 표시하는 뷰
        } else {
            EmptyView()
        }
    }
}

#Preview {
    TimetableView()
}
