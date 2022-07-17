//
//  AuthorizationAPI.swift
//  Naenio
//
//  Created by 조윤영 on 2022/07/14.
//
/*
 API endpoint 케이스 정의
 //TODO: API 명세서 확정될 시,URI 및 request 형식 변경
 */

import Moya

enum NaenioAPI {
    case login(LoginRequestInformation)
    case signOut(token: String)
    case withDrawal(token: String)
}

extension NaenioAPI: TargetType {
    var baseURL: URL { return URL(string: KeyValue.baseURL)! }

    var path: String { self.getPath() }
    
    var method: Moya.Method { return .post }
  
    var sampleData: Data { Data() }
    
    var task: Task { self.getTask() }

    var headers: [String: String]? {
        switch self {
        case .login:
            return [HeaderInformation.HeaderKey.contentType: HeaderInformation.HeaderValue.json]
        default:
            return [
                HeaderInformation.HeaderKey.contentType: HeaderInformation.HeaderValue.json,
                HeaderInformation.HeaderValue.authoization: HeaderInformation.HeaderValue.authoization
            ]
        }
    }
}