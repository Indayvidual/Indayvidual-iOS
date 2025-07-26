//
//  SchoolInfoService.swift
//  Indayvidual
//
//  Created by 장주리 on 7/23/25.
//

import Foundation
import Moya

class SchoolInfoService {
    private let provider = MoyaProvider<SchoolInfoTarget>()
    
    func fetchSchoolNames(apiKey: String, searchTxt: String, completion: @escaping (Result<[SchoolInfo], Error>) -> Void) {
        provider.request(.getSchoolInfo(apiKey: apiKey, searchTxt: searchTxt)) { result in
            print("--- API 요청 결과 ---")
            
            switch result {
            case .success(let response):
                //print("✅ 성공: 상태 코드 - \(response.statusCode)")
                if String(data: response.data, encoding: .utf8) != nil {
                } else {
                    print("데이터를 문자열로 변환할 수 없습니다.")
                }

                do {
                    let schoolData = try JSONDecoder().decode(SchoolData.self, from: response.data)
                    completion(.success(schoolData.dataSearch.content))
                } catch {
                    print("❌ 디코딩 실패: \(error.localizedDescription)")
                    completion(.failure(error))
                }

            case .failure(let error):
                print("❌ 요청 실패: \(error.localizedDescription)")
                print("상세 정보: \(error)")
                completion(.failure(error))
            }
            
            print("--------------------")
        }
    }
}
