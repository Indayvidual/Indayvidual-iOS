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
            ZStack(alignment: .topTrailing) {
                mainContent
                
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
                    } else {
                        EmptyView()
                    }
                }
            }
            .onAppear {
                Task {
                    if !timetableVm.isLoading{
                        await timetableVm.fetchTimetable()
                    }
                }
            }
                .floatingBtn { timetableVm.showImagePicker = true }
                .photosPicker(
                    isPresented: $timetableVm.showImagePicker,
                    selection: $timetableVm.selectedPhotoItem,
                    matching: .images
                )
                .background(Color(.gray50))
                
                // 학교/학기 설정 뷰
                .navigationDestination(isPresented: $timetableVm.showSchoolSemesterSetup) {
                    SchoolSemesterSetupView(
                        timetableVm: timetableVm
                    )
                }
        }
        
        // 안내 팝업
        .overlay {
            if !timetableVm.isSchoolRegistered && timetableVm.showNoticePopup { // 학교/학기 미등록 상태일 경우 안내 팝업창 뜸
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
        VStack(alignment: .leading, spacing: 0) {
            Topbar(customAction: {
                timetableVm.showDeleteButton.toggle()
                print(timetableVm.showDeleteButton)
            })
            
            Spacer().frame(height: 10)
            
            HStack(spacing: 12) {
                
                Text(timetableVm.formattedSelection() ?? "학교/학기 선택")
                    .font(.pretendRegular13)
                    .foregroundStyle(timetableVm.formattedSelection() == nil ? Color(.gray500) : Color(.gray900))
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
    
    @ViewBuilder
    func timetableContent() -> some View {
        if let selectedImage = timetableVm.selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .padding()
        }  else {
            // 이미지가 없을 때 보여줄 기본 뷰
            EmptyTimeTableView()
        }
    }
}

#Preview {
    TimetableView()
}
