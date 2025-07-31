//
//  SchoolSearchPopup.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI

struct SchoolSearchPopup: View {
    @Binding var isPresented: Bool
    @Binding var selectedSchoolName: String?
    
    @StateObject private var viewModel = SchoolInfoViewModel()
    @State private var selectedSchool: SchoolInfo? = nil
    @State private var searchText: String = ""
    @State private var searchPerformed: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    isPresented = false
                }
            
            VStack(spacing: 0) {
                Spacer()
                
                CustomActionSheet(
                    title: "학교 설정",
                    primaryButtonTitle: "저장",
                    primaryAction: {
                        if selectedSchool != nil {
                            selectedSchoolName = selectedSchool?.name
                            isPresented = false
                        }
                    },
                    secondaryAction: {
                        isPresented = false
                    },
                    showDivider: false,
                    primaryButtonColor: searchText == "" ? .gray100 : .gray900
                ) {
                    VStack(spacing: 0) {
                        searchBar
                            .padding(.top, 10)
                        
                        Divider()
                            .padding(.vertical, 15)
                        
                        // 검색 후에만 리스트 또는 로딩 뷰 출력
                        if searchPerformed {
                            schoolList
                                .frame(maxHeight: 210) // 검색창 등 제외한 나머지 높이
                        }
                    }
                    .padding(.horizontal, 20)
                    .background(Color.white)
                }
                .frame(maxWidth: 350)
                .background(Color.white)
                .cornerRadius(15)
                Spacer()
            }
        }
    }
    
    private var searchBar: some View {
        SearchTextField(text: $searchText) { newValue in
            if newValue.isEmpty {
                searchPerformed = false
                viewModel.schoolNames = []
            } else {
                searchPerformed = true
                viewModel.search(with: newValue)
            }
        }
    }
    
    @ViewBuilder
    private var schoolList: some View {
        if viewModel.isLoading {
            VStack {
                Spacer()
                ProgressView("학교를 검색하는 중...")
                Spacer()
            }
            .frame(maxWidth: .infinity)
        } else if let errorMessage = viewModel.errorMessage {
            VStack {
                Spacer()
                Text(errorMessage)  /// 검색 키워드 없을 경우 메세지 띄움
                    .foregroundColor(viewModel.schoolNames.isEmpty ? .gray : .red)
                Spacer()
            }
            .frame(maxWidth: 210)
        } else {
            List(viewModel.schoolNames) { school in
                SchoolRow(school: school, selectedSchool: $selectedSchool)
                    .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
        
        
    }
    
    struct SchoolRow: View {
        let school: SchoolInfo
        @Binding var selectedSchool: SchoolInfo?

        var isSelected: Bool {
            selectedSchool?.id == school.id
        }

        var body: some View {
            HStack(spacing: 10) {
                Button(action: { selectedSchool = school }) {
                    Image(isSelected ? "ic_24_bell_fill" : "ic_24_bell")
                }

                Text(school.name)
                    .font(.pretendMedium14)
                    .foregroundStyle(Color(.gray900))
            }
            .padding(.vertical, 20)
            .contentShape(Rectangle())
            .onTapGesture {
                selectedSchool = school
            }
        }
    }
}

#Preview {
    SchoolSearchPopupPreviewWrapper()
}

private struct SchoolSearchPopupPreviewWrapper: View {
    @State private var isPresented = true
    @State private var selectedSchoolName: String? = nil
    
    var body: some View {
        SchoolSearchPopup(
            isPresented: $isPresented,
            selectedSchoolName: $selectedSchoolName
        )
    }
}
