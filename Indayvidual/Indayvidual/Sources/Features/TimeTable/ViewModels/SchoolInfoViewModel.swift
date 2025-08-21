//
//  SchoolInfoViewModel.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import Foundation

class SchoolInfoViewModel: ObservableObject {
    @Published var schoolNames: [SchoolInfo] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private let service = SchoolInfoService()
    private let apiKey: String
    private var searchWorkItem: DispatchWorkItem?

    init() {
        if let key = Bundle.main.infoDictionary?["SCHOOL_INFO_API_KEY"] as? String {
            self.apiKey = key
        } else {
            self.apiKey = ""
            self.errorMessage = "API 키가 설정되어 있지 않습니다."
            print("API 키가 설정되어 있지 않습니다.")
        }
    }

    /// 사용자 입력 시 호출되는 실시간 검색 함수 (디바운싱 적용)
    func search(with searchText: String) {
        searchWorkItem?.cancel()
        
        guard !searchText.isEmpty else {
            self.schoolNames = []
            self.errorMessage = nil
            return
        }

        let newWorkItem = DispatchWorkItem {
            self.fetchSchools(searchTxt: searchText, showEmptyMessage: true, sort: false)
        }

        searchWorkItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: newWorkItem) // 디바운싱 시간 0.3초로 단축
    }

    /// 전체 학교 불러올 때 사용 (정렬 적용)
    func loadAllSchools(searchTxt: String) {
        fetchSchools(searchTxt: searchTxt, showEmptyMessage: false, sort: true)
    }

    /// 학교 목록을 API로 불러오는 공통 함수
    /// - Parameters:
    ///   - searchTxt: 검색어
    ///   - showEmptyMessage: 결과가 없을 때 메시지 표시 여부
    ///   - sort: 결과 정렬 여부
    private func fetchSchools(searchTxt: String, showEmptyMessage: Bool, sort: Bool) {
        guard !apiKey.isEmpty else { return }

        // 로딩 시작 표시
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        service.fetchSchoolNames(apiKey: apiKey, searchTxt: searchTxt) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let schools):
                    var resultSchools = schools
                    print(resultSchools)
                    if sort {
                        resultSchools.sort { $0.name < $1.name }
                    }
                    self?.schoolNames = resultSchools

                    // 결과 없음 메시지 처리
                    if showEmptyMessage && schools.isEmpty {
                        self?.errorMessage = "'\(searchTxt)'에 대한 검색 결과가 없습니다."
                    }

                case .failure(let error):
                    self?.errorMessage = "학교 정보를 불러오는데 실패했습니다: \(error.localizedDescription)"
                }
            }
        }
    }
}
