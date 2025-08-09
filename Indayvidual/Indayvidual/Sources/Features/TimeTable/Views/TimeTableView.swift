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
                .floatingBtn { timetableVm.showImagePicker = true }
                .photosPicker(
                    isPresented: $timetableVm.showImagePicker,
                    selection: $timetableVm.selectedPhotoItem,
                    matching: .images
                )
                .background(Color(.gray50))
                .navigationDestination(isPresented: $timetableVm.navigateToSchoolSemesterRegistration) {
                    SchoolSemesterSetupView(
                        timetableVm: timetableVm,
                        onCompletion: { school, semester in
                            // 저장 후 팝업 닫고 등록 완료 상태 변경
                            timetableVm.isSchoolRegistered = true
                            timetableVm.showSchoolSemesterSetup = false
                            timetableVm.showSchoolSearchPopup = false
                            timetableVm.navigateToSchoolSemesterRegistration = false
                            // 선택된 학교/학기 업데이트
                            timetableVm.updateSchoolSemester(schoolName: school, semester: semester)
                        }
                    )
                }
        }
        // 학교/학기 설정 시트뷰
        .overlay {
            if timetableVm.showSchoolSemesterSetup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { timetableVm.showSchoolSemesterSetup = false }
                
                VStack {
                    Spacer()
                    SchoolSemesterSetupView(
                        timetableVm: timetableVm,
                        onCompletion: timetableVm.handleSchoolRegistrationCompletion,
                        onSetupTapped: timetableVm.handleSchoolRegistrationSetupTap
                    )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        
        // 학교 검색 시트 팝업
        .overlay {
            if timetableVm.showSchoolSearchPopup {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture { timetableVm.showSchoolSearchPopup = false }
                
                VStack {
                    Spacer()
                    NoticePopupView(
                        showModal: $timetableVm.showSchoolSearchPopup,
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
            Topbar()
            
            Spacer().frame(height: 10)
        
            HStack(spacing: 12){
                Text(timetableVm.formattedSelection() ?? "학교/학기 선택")
                    .font(.pretendRegular13)
                    .foregroundStyle(timetableVm.selection == nil ? Color(.gray500) : Color(.gray900))
                    .lineLimit(1)
                   
                Image(.mingcuteDownFill)
            }
            .padding(.horizontal, 12)
            .frame(height: 28)
            .background(Color.white)
            .contentShape(Rectangle())
            .onTapGesture {
                timetableVm.showSchoolSemesterSetup = true
            }
            
            
            
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
