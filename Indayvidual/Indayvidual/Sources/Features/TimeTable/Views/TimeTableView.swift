//
//  TimetableView.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI
import Kingfisher

struct TimetableView: View {
    @StateObject private var timetableVm = TimetableViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                mainContent
                
                // 삭제 버튼
                if timetableVm.showDeleteButton {
                    if let timetableId = timetableVm.currentTimetable?.timetableId {
                        Button(action: {
                            timetableVm.deleteTimetable(timetableId: timetableId)
                            timetableVm.showDeleteButton = false
                        }) {
                            Text("삭제하기")
                                .foregroundColor(.red)
                                .font(.pretendSemiBold9)
                                .frame(width: 65, height: 31)
                                .background(Color.white)
                        }
                        .padding(.top, 40)
                        .padding(.trailing, 13)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.easeInOut, value: timetableVm.showDeleteButton)
                    }
                }
            }
            .task {
                timetableVm.loadSavedSchool()
                
                if !timetableVm.isLoading {
                    await timetableVm.fetchTimetable()
                }
            }
            .floatingBtn { timetableVm.showImagePicker = true }
            .photosPicker(
                isPresented: $timetableVm.showImagePicker,
                selection: $timetableVm.selectedPhotoItem,
                matching: .images
            )
            .background(Color(.gray50))
            .navigationDestination(isPresented: $timetableVm.showSchoolSemesterSetup) {
                SchoolSemesterSetupView(timetableVm: timetableVm)
            }
        }
        .overlay {
            // 학교 미등록 시 안내 팝업
            if !timetableVm.isSchoolRegistered && timetableVm.showNoticePopup {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { timetableVm.showNoticePopup = false }
                
                VStack {
                    Spacer()
                    NoticePopupView(
                        onSetupTapped: {
                            timetableVm.isSchoolRegistered = true
                            timetableVm.showSchoolSemesterSetup = true
                        }
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
    var mainContent: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                // 상단 바
                Topbar(customAction: {
                    timetableVm.showDeleteButton.toggle()
                })
                
                Spacer().frame(height: 10)
                
                HStack(spacing: 12) {
                    // 학교 선택
                    SchoolSelectionBar(
                        schoolName: $timetableVm.selectedSchoolName,
                        onTap: { timetableVm.showSchoolSemesterSetup = true }
                    )
                    
                    // 학기 선택(드롭다운)
                    SemesterSelectionBar(
                        selection: Binding(
                            get: { timetableVm.selectedSemester?.rawValue },
                            set: { newValue in
                                if let value = newValue,
                                   let semester = Semester(rawValue: value) {
                                    timetableVm.selectSemester(semester)
                                }
                            }
                        )
                    )
                    
                }
                .padding(.leading, 25)
                .zIndex(10)
                
                Spacer().frame(height: 20)
                
                // 시간표 콘텐츠
                HStack {
                    Spacer()
                    timetableContent()
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    func timetableContent() -> some View {
        if timetableVm.isLoading {          // 로딩 인디케이터
            VStack{
                Spacer()
                ProgressView("이미지 로딩중..")
                Spacer()
            }
        } else if let imageURL = timetableVm.selectedImageURL {
            KFImage(imageURL)
                .resizable()
                .scaledToFit()
                .padding()
        } else {
            EmptyTimeTableView()
        }
    }
    
    // 학교 선택바
    struct SchoolSelectionBar: View {
        var cornerRadius: CGFloat = 4
        @Binding var schoolName: String?
        var onTap: () -> Void
        
        var body: some View {
            Text(schoolName ?? "학교 선택")
                .font(.pretendRegular13)
                .foregroundColor(schoolName == nil ? Color.gray : Color.black)
                .frame(height: 28)
                .padding(.horizontal, 20)
                .background(Color.white)
                .cornerRadius(cornerRadius)
                .contentShape(Rectangle())
                .onTapGesture {
                    onTap()
                }
        }
    }
}

#Preview {
    TimetableView()
}
