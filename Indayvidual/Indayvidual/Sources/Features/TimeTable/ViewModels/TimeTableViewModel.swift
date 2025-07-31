//
//  TimetableViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI
import PhotosUI

@MainActor
class TimetableViewModel: ObservableObject {

    // MARK: - 학교/학기 등록 관련 상태
    @Published var isSchoolRegistered: Bool // 학교 등록 여부
    var selectedSchoolName: String?
    var selectedSemester: String?

    // MARK: - 시간표 선택 및 이미지 관리
    @Published var selection: String? {
        didSet {
            // 선택된 시간표에 맞는 이미지 갱신
            if let sel = selection {
                selectedImage = timetableImages[sel]
            } else {
                selectedImage = nil
            }
        }
    }
    @Published var selectedImage: UIImage?
    @Published var dropdownOptions: [String] = [] // 시간표 목록
    @Published var timetableImages: [String: UIImage] = [:] // 각 시간표별 이미지 저장

    // MARK: - PhotosPicker 관련 상태
    @Published var showImagePicker = false
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            Task {
                await processSelectedPhoto()
            }
        }
    }
    
    // MARK: - 팝업/네비게이션 제어용 상태 (뷰에서 바인딩하여 사용)
    @Published var showSchoolSheet = false
    @Published var showSemesterSheet = false
    @Published var showSchoolRegistrationPopup = false
    @Published var showSchoolSetupOverlay = false
    @Published var navigateToSchoolSemesterRegistration = false

    // MARK: - 초기화
    init() {
        self.isSchoolRegistered = false
    }

    // MARK: - 사진 처리 비동기 함수
    private func processSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let key = selection {

                DispatchQueue.main.async {
                    self.timetableImages[key] = image
                    self.selectedImage = image
                    self.selectedPhotoItem = nil // 다음 선택을 위해 초기화
                }
            }
        } catch {
            print("Failed to load image: \(error)")
        }
    }

    // MARK: - 학교/학기 등록 처리 함수들

    /// 학기 선택 시 시트 닫히면서 선택 처리
    func handleSemesterSheetDismiss() {
        guard let school = selectedSchoolName, let semester = selectedSemester else { return }

        let newEntry = "\(school) \(semester)"
        if !dropdownOptions.contains(newEntry) {
            dropdownOptions.append(newEntry)
        }
        selection = newEntry

        // 선택된 시간표에 이미지가 없으면 사진 선택기 실행
        if timetableImages[newEntry] == nil {
            showImagePicker = true
        }
    }

    /// 학교 및 학기 정보로 시간표 업데이트 및 등록 완료 처리
    func updateSchoolSemester(schoolName: String, semester: String) {
        let newEntry = "\(schoolName) \(semester)"
        if !dropdownOptions.contains(newEntry) {
            dropdownOptions.append(newEntry)
        }
        selection = newEntry
        isSchoolRegistered = true
    }

    // MARK: - 뷰 관련 호출 함수

    /// 뷰가 나타날 때 호출, 학교 등록 여부 체크 후 오버레이 표시
    func onAppear() {
        if !isSchoolRegistered {
            showSchoolSetupOverlay = true
        }
    }

    /// 학교/학기 등록 팝업에서 저장 완료 시 호출
    func handleSchoolRegistrationCompletion(schoolName: String, semester: String) {
        updateSchoolSemester(schoolName: schoolName, semester: semester)
        showSchoolRegistrationPopup = false
    }

    /// 학교/학기 등록 팝업 내 '설정하러 가기' 버튼 탭 시 호출
    func handleSchoolRegistrationSetupTap() {
        showSchoolRegistrationPopup = false
        showSchoolSetupOverlay = true
    }

    /// 학교 설정 오버레이 내 '설정하러 가기' 버튼 탭 시 호출
    func handleSchoolSetupTapped() {
        showSchoolSetupOverlay = false
        navigateToSchoolSemesterRegistration = true // 네비게이션 트리거
    }

    /// 학교 설정 오버레이 내 완료 시 호출
    func handleSchoolSetupCompletion(schoolName: String, semester: String) {
        showSchoolSetupOverlay = false
        navigateToSchoolSemesterRegistration = true
    }
}
