//
//  TimetableViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI
import PhotosUI
import Moya
import Kingfisher

@MainActor
class TimetableViewModel: ObservableObject {
    private let timetableProvider = MoyaProvider<TimetableTarget>()
    private var alertService: AlertService?
    
    // MARK: - 선택 상태
    @Published var selectedSemester: Semester? = nil
    @Published var showSemesterDropdown = false
    @Published var selectedSchoolSeq: String? = nil
    @Published var selectedSchoolName: String?
    
    @Published var isPosting: Bool = false
    @Published var isLoading: Bool = false
    @Published var isSchoolRegistered: Bool
    
    @Published var selectedImageURL: URL?
    
    // MARK: - 뷰 상태
    @Published var showSchoolSearchPopup = false
    @Published var showSchoolSemesterSetup = false
    @Published var showNoticePopup = false
    @Published var showDeleteButton = false
    @Published var showImagePicker = false
    
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            if selectedPhotoItem != nil {
                processSelectedPhoto()
            }
        }
    }
    
    // MARK: - 시간표 데이터
    @Published var timeTable: [TimetableDto]? = nil
    @Published var currentTimetable: TimetableDto?
    
    init(alertService: AlertService? = nil) {
        self.isSchoolRegistered = false
        self.alertService = alertService
        loadSavedSchool()
    }
    
    func setup(alertService: AlertService) {
        self.alertService = alertService
    }
    
    // MARK: - UserDefaults에서 저장된 학교/학기 불러오기
    func loadSavedSchool() {
        let defaults = UserDefaults.standard
        if let savedSeq = defaults.string(forKey: "savedSchoolSeq"),
           let savedName = defaults.string(forKey: "savedSchoolName"),
           let savedSemesterRaw = defaults.string(forKey: "savedSemester"),
           let savedSemester = Semester(rawValue: savedSemesterRaw) {
            self.selectedSchoolSeq = savedSeq
            self.selectedSchoolName = savedName
            self.selectedSemester = savedSemester
            self.isSchoolRegistered = true
            self.showNoticePopup = false
            print("UserDefaults에서 불러온 학교: \(savedName) (\(savedSeq))")
        }
    }
    
    // MARK: - 이미지 처리
    private func processSelectedPhoto() {
        guard let item = selectedPhotoItem else { return }
        
        _Concurrency.Task {
            do {
                guard let imageData = try await item.loadTransferable(type: Data.self) else {
                    print("이미지 데이터 로딩에 실패했습니다.")
                    return
                }
                
                print("selectedImageData 준비 완료") // 디버깅용
                self.postTimetable(imageData: imageData) { success in
                    if success {
                        print("시간표 등록 성공! 🎉")
                        self.selectedPhotoItem = nil
                        _Concurrency.Task { await self.fetchTimetable() }
                    } else {
                        print("시간표 등록 실패!")
                    }
                }
            } catch {
                print("이미지 로딩 실패: \(error)")
                alertService?.showAlert(
                    message: "이미지 로딩 실패 \n 잠시 후 다시 시도해 주세요",
                    primaryButton: .primary(title: "확인", action: {})
                )
            }
        }
    }
    
    // MARK: - 시간표 등록 API
    func postTimetable(imageData: Data, completion: ((Bool) -> Void)? = nil) {
        guard !isPosting,
              let schoolId = selectedSchoolSeq,
              let schoolName = selectedSchoolName,
              let semester = selectedSemester?.rawValue
        else {
            print("API 호출에 필요한 정보(학교/학기)가 부족합니다.")
            completion?(false)
            return
        }
        
        isPosting = true
        
        timetableProvider.request(.postTimetable(schoolId: schoolId, schoolName: schoolName, semester: semester, image: imageData)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isPosting = false
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        print("👍🏻 시간표 등록 성공")
                        completion?(true)
                    } else if response.statusCode == 409 {
                        // 409 에러 처리
                        print("🟡 409 에러 발생: 시간표 이미 존재")
                        self?.alertService?.showAlert(
                            message: "이미 해당 학기의 시간표가 존재합니다. \n 삭제 후 다시 등록해주세요.",
                            primaryButton: .primary(title: "확인", action: {})
                        )
                        completion?(false)
                    } else {
                        // 그 외 서버 에러 처리
                        print("🔴 서버 에러 발생: 상태 코드 \(response.statusCode)")
                        completion?(false)
                    }
                    
                case .failure(let error):
                    // 네트워크 에러 처리
                    print("🔴 네트워크 에러: \(error.localizedDescription)")
                    self?.alertService?.showAlert(message: "네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.", primaryButton: .primary(title: "확인", action: {}))
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - 시간표 조회 API
    func fetchTimetable() async {
        DispatchQueue.main.async { self.isLoading = true }
        do {
            let response = try await withCheckedThrowingContinuation { continuation in
                timetableProvider.request(.getTimetable) { result in
                    continuation.resume(with: result)
                }
            }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                guard (200...299).contains(response.statusCode) else {
                    if response.statusCode == 404 {
                        print("INFO: 등록된 시간표가 없습니다.")
                        self.currentTimetable = nil
                        self.isSchoolRegistered = false
                    } else {
                        let responseBody = String(data: response.data, encoding: .utf8) ?? "No readable response body"
                        print("🟡 시간표 조회 실패 [\(response.statusCode)]: \(responseBody)")
                    }
                    return
                }
                
                do {
                    let apiResponse = try JSONDecoder().decode(APIResponseDto<[TimetableDto]>.self, from: response.data)
                    self.timeTable = apiResponse.data
                    
                    if apiResponse.data.isEmpty {
                        self.currentTimetable = nil
                        self.showNoticePopup = true
                    } else {
                        self.isSchoolRegistered = true
                        self.showNoticePopup = false
                        self.setLatestTimetable(from: apiResponse.data)
                    }
                    
                    print("✅ 시간표 조회 성공: \(apiResponse.data)")
                } catch {
                    print("🔴 JSON 디코딩 실패: \(error.localizedDescription)")
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                print("🔴 네트워크 에러: \(error.localizedDescription)")
                self.alertService?.showAlert(message: "네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.", primaryButton: .primary(title: "확인", action: {}))
            }
        }
    }
    
    // MARK: - 시간표 삭제 API
    func deleteTimetable(timetableId: Int, completion: ((Bool) -> Void)? = nil) {
        guard !isPosting else {
            completion?(false)
            return
        }
        isPosting = true
        
        timetableProvider.request(.deleteTimetable(timetableId: timetableId)) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isPosting = false
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        print("✅ 시간표 삭제 성공 (ID: \(timetableId))")
                        if let index = self.timeTable?.firstIndex(where: { $0.timetableId == timetableId }) {
                            self.timeTable?.remove(at: index)
                        }
                        
                        self.selectedImageURL = nil
                        self.currentTimetable = nil
                        completion?(true)
                    } else {
                        let responseBody = String(data: response.data, encoding: .utf8) ?? "No readable response body"
                        print("🟡 시간표 삭제 실패 [\(response.statusCode)]: \(responseBody)")
                        self.alertService?.showAlert(message: "시간표 삭제 실패를 실패 했습니다. \n 다시 시도 해주세요. \(response.statusCode)", primaryButton: .primary(title: "확인", action: {}))
                        completion?(false)
                    }
                case .failure(let error):
                    print("🔴 시간표 삭제 요청 실패 (네트워크 에러): \(error.localizedDescription)")
                    self.alertService?.showAlert(message: "네트워크 에러: \(error.localizedDescription)", primaryButton: .primary(title: "확인", action: {}))
                    completion?(false)
                }
            }
        }
    }
    
    // MARK: - 최신 시간표 설정 (Kingfisher 적용 + 로딩)
    func setLatestTimetable(from timetables: [TimetableDto]?) {
        guard let timetables = timetables, !timetables.isEmpty else {
            self.currentTimetable = nil
            self.selectedImageURL = nil
            return
        }
        
        let latestTimetable = timetables.max { $0.timetableId < $1.timetableId }
        self.currentTimetable = latestTimetable
        
        if let timetable = latestTimetable,
           let url = URL(string: timetable.imageUrl) {
            self.selectedSemester = Semester(rawValue: timetable.semester)
            self.selectedSchoolName = timetable.schoolName
            
            self.selectedImageURL = url
        } else {
            self.selectedImageURL = nil
        }
    }
    
    
    // MARK: - 학교/학기 등록
    func saveSchoolSemester(schoolSeq: String, schoolName: String, semester: Semester) {
        self.selectedSchoolSeq = schoolSeq
        self.selectedSchoolName = schoolName
        self.selectedSemester = semester
        self.isSchoolRegistered = true
        self.showNoticePopup = false
        self.showSchoolSemesterSetup = false
        
        self.timeTable = nil
        self.currentTimetable = nil
        self.selectedImageURL = nil
        
        // UserDefaults에 저장
        let defaults = UserDefaults.standard
        defaults.set(schoolSeq, forKey: "savedSchoolSeq")
        defaults.set(schoolName, forKey: "savedSchoolName")
        defaults.set(semester.rawValue, forKey: "savedSemester")
        
        print("저장된 학교 seq: \(schoolSeq), 이름: \(schoolName), 학기: \(semester.rawValue)")
    }
    
    // MARK: - 학기 선택
    func selectSemester(_ semester: Semester) {
        self.selectedSemester = semester
        self.showSemesterDropdown = false
        
        if let timetables = timeTable,
           let matched = timetables.first(where: { $0.semester == semester.rawValue }),
           let url = URL(string: matched.imageUrl) {
            self.currentTimetable = matched
            self.selectedImageURL = url
        } else {
            self.currentTimetable = nil
            self.selectedImageURL = nil
        }
    }
    
    /// 시간표 등록 여부 확인
    var hasRegisteredTimetable: Bool {
        return !(timeTable?.isEmpty ?? true)
    }
}
