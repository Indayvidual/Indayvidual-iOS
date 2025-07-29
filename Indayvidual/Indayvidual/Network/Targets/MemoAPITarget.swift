//
//  MemoAPITarget.swift
//  Indayvidual
//
//  Created by 김도연 on 7/28/25.
//

import Foundation
import Moya

enum MemoAPITarget {
    case getMemos
    case postMemos(title: String, content: String)
    case getMemosInfo(memoId: Int)
    case deleteMemos(memoId: Int)
    case patchMemos(memoId: Int, title: String, content: String)
}

extension MemoAPITarget: APITargetType {
    var path: String {
        switch self {
        case .getMemos, .postMemos:
            return "/api/custom/memos"
        case .getMemosInfo(let memoId), .deleteMemos(let memoId), .patchMemos(let memoId, _, _):
            return "/api/custom/memos/\(memoId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getMemos, .getMemosInfo:
            return .get
        case .patchMemos:
            return .patch
        case .postMemos:
            return .post
        case .deleteMemos:
            return .delete
        }
    }
    
    var task: Task {
        switch self {
        case .getMemos, .getMemosInfo, .deleteMemos:
            return .requestPlain
            
        case .postMemos(let title, let content):
            let parameters: [String: Any] = [
                "title": title,
                "content": content
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .patchMemos(_, let title, let content):
            let parameters: [String: Any] = [
                "title": title,
                "content": content
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        }
    }
    

    
    var headers: [String : String]? {
        return ["Content-Type": "application/json"]
    }
}
