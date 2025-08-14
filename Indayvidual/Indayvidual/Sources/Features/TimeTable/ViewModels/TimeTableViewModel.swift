//
//  TimetableViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/31/25.
//

import SwiftUI
import PhotosUI
import Moya

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
    @Published var selectedImage: UIImage?
    
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
    }
    
    func setup(alertService: AlertService) {
        self.alertService = alertService
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
                
                self.selectedImage = UIImage(data: imageData)
                print("selectedImage가 성공적으로 할당되었습니다.")
                
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
                    message: "이미지 로딩 실패: \(error.localizedDescription)",
                    primaryButton: .primary(title: "확인")
                )
            }
        }
    }
    
    // MARK: - 시간표 등록 API
    func postTimetable(imageData: Data, completion: ((Bool) -> Void)? = nil) {
        guard !isPosting,
              let schoolId = selectedSchoolSeq,
              let semester = selectedSemester?.rawValue
        else {
            print("API 호출에 필요한 정보(학교/학기)가 부족합니다.")
            completion?(false)
            return
        }
        
        isPosting = true
        
        timetableProvider.request(.postTimetable(schoolId: schoolId, semester: semester, image: imageData)) { [weak self] result in
            DispatchQueue.main.async {
                self?.isPosting = false
                switch result {
                case .success(let response):
                    if (200...299).contains(response.statusCode) {
                        self?.alertService?.showAlert(message: "시간표 등록 성공했습니다.", primaryButton: .primary(title: "확인"))
                        completion?(true)
                    } else {
                        let responseBody = String(data: response.data, encoding: .utf8) ?? "No readable response body"
                        print("🟡 Server Error Response [\(response.statusCode)]: \(responseBody)")
                        self?.alertService?.showAlert(message: "시간표 등록 실패 (서버 에러): 코드 \(response.statusCode)", primaryButton: .primary(title: "확인"))
                        completion?(false)
                    }
                case .failure(let error):
                    print("🔴 Moya Failure: \(error.localizedDescription)")
                    self?.alertService?.showAlert(message: "네트워크 에러: \(error.localizedDescription)", primaryButton: .primary(title: "확인"))
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
                        self.alertService?.showAlert(message: "시간표를 불러오는데 실패했습니다.", primaryButton: .primary(title: "확인"))
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
                    self.alertService?.showAlert(message: "데이터 처리 중 오류가 발생했습니다.", primaryButton: .primary(title: "확인"))
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.isLoading = false
                print("🔴 네트워크 에러: \(error.localizedDescription)")
                self.alertService?.showAlert(message: "네트워크 오류가 발생했습니다. 잠시 후 다시 시도해 주세요.", primaryButton: .primary(title: "확인"))
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
                        self.alertService?.showAlert(message: "시간표가 성공적으로 삭제되었습니다.", primaryButton: .primary(title: "확인"))
                        self.clearSelectionAfterDelete()
                        completion?(true)
                    } else {
                        let responseBody = String(data: response.data, encoding: .utf8) ?? "No readable response body"
                        print("🟡 시간표 삭제 실패 [\(response.statusCode)]: \(responseBody)")
                        self.alertService?.showAlert(message: "시간표 삭제 실패 (서버 에러): 코드 \(response.statusCode)", primaryButton: .primary(title: "확인"))
                        completion?(false)
                    }
                case .failure(let error):
                    print("🔴 Moya Failure: \(error.localizedDescription)")
                    self.alertService?.showAlert(message: "네트워크 에러: \(error.localizedDescription)", primaryButton: .primary(title: "확인"))
                    completion?(false)
                }
            }
        }
    }
    
    private func clearSelectionAfterDelete() {
        self.isLoading = false
        self.showNoticePopup = true
        self.selectedImage = nil
        self.selectedSchoolName = nil
        self.selectedSchoolSeq = nil
        self.selectedSemester = nil
    }
    
    // MARK: - 최신 시간표 설정
    func setLatestTimetable(from timetables: [TimetableDto]?) {
        guard let timetables = timetables, !timetables.isEmpty else {
            print("INFO: 시간표 리스트가 비어있어 최신 항목을 설정할 수 없습니다.")
            self.currentTimetable = nil
            self.selectedImage = nil
            return
        }
        
        let latestTimetable = timetables.max { $0.timetableId < $1.timetableId }
        self.currentTimetable = latestTimetable
        
        if let timetable = latestTimetable {
            self.selectedSemester = Semester(rawValue: timetable.semester)
            self.selectedSchoolName = timetable.schoolName
            
            if let url = URL(string: timetable.imageUrl) {
                _Concurrency.Task {
                    do {
                        let (data, _) = try await URLSession.shared.data(from: url)
                        DispatchQueue.main.async {
                            self.selectedImage = UIImage(data: data)
                        }
                    } catch {
                        print("이미지 다운로드 실패: \(error.localizedDescription)")
                        DispatchQueue.main.async { self.selectedImage = nil }
                    }
                }
            } else {
                self.selectedImage = nil
            }
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
        self.selectedImage = nil
        self.isLoading = true
        print("저장된 학교 seq: \(schoolSeq), 이름: \(schoolName), 학기: \(semester.rawValue)")
    }
    
    // MARK: - 학년-학기 포맷
    func formattedSelection() -> String? {
        guard let school = selectedSchoolName, let semester = selectedSemester else { return nil }
        let pattern = #"(\d)학년\s*(\d)학기"#
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: semester.rawValue, range: NSRange(semester.rawValue.startIndex..., in: semester.rawValue)) {
            if let yearRange = Range(match.range(at: 1), in: semester.rawValue),
               let semRange = Range(match.range(at: 2), in: semester.rawValue) {
                let year = semester.rawValue[yearRange]
                let sem = semester.rawValue[semRange]
                return "\(school) \(year)-\(sem)"
            }
        }
        return "\(school) \(semester.rawValue)"
    }
    
    func selectSemester(_ semester: Semester) {
        self.selectedSemester = semester
        self.showSemesterDropdown = false
    }
}
