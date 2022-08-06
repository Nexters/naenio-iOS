//
//  AppleLoginTestViewModels.swift
//  Naenio
//
//  Created by 프라이빗 on 2022/07/10.
//

import SwiftUI
import AuthenticationServices
import KakaoSDKAuth
import RxSwift

class LoginViewModel: ObservableObject {
    // Dependencies
    let appleLoginManager: AppleLoginManager
    let kakaoLoginManager: KakaoLoginManager
    let concurrentQueue = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    // Published vars
    /// 로그인 루틴 처리 상태를 표시
    @Published var status: Status = .waiting
    
    // Private vars
    private let bag = DisposeBag()
    
    // MARK: - For apple
    func handleAppleLoginResult(result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authResult):
            requestAppleLoginToServer(with: authResult)
        case .failure(let error):
            status = .fail(with: error)
        }
    }
    
    private func requestAppleLoginToServer(with result: ASAuthorization) {
        appleLoginManager.requestLoginToServer(with: result).subscribe(on: self.concurrentQueue)
            .subscribe(
                onSuccess: { [weak self] userInfo in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.status = .done(result: userInfo)
                    }
                },
                onFailure: { [weak self] error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.status = .fail(with: error)
                    }
                },
                onDisposed: {
                }
            )
            .disposed(by: bag)
    }
    
    // MARK: - For kakao
    func handleKakaoLoginResult(result: Result<OAuthToken, Error>) {
        switch result {
        case .success(let authResult):
            requestKakaoLoginToServer(with: authResult)
        case .failure(let error):
            status = .fail(with: error)
        }
    }
    
    private func requestKakaoLoginToServer(with result: OAuthToken) {
        kakaoLoginManager.requestLoginToServer(with: result)
            .subscribe(on: self.concurrentQueue)
            .subscribe(
                onSuccess: { [weak self] userInfo in
                    guard let self = self else { return }
                    // Save(userInfo)
                    DispatchQueue.main.async {
                        self.status = .done(result: userInfo)
                    }
                },
                onFailure: { [weak self] error in
                    guard let self = self else { return }
                    DispatchQueue.main.async {
                        self.status = .fail(with: error)
                    }
                },
                onDisposed: {
#if DEBUG
                    print("disposed")
#endif
                }
            )
            .disposed(by: bag)
    }
    
    init(_ appleLoginManager: AppleLoginManager = AppleLoginManager(),
         _ kakaoLoginManager: KakaoLoginManager = KakaoLoginManager()) {
        self.appleLoginManager = appleLoginManager
        self.kakaoLoginManager = kakaoLoginManager
    }
    
#if DEBUG
    deinit {
        print("LoginTestViewModel deinit")
    }
#endif
}

extension LoginViewModel {
    enum Status {
        case waiting
        case inProgress
        case done(result: UserInformation)
        case fail(with: Error)
        
        var description: String {
            switch self {
            case .waiting:
                return "Waiting"
            case .inProgress:
                return "In progres..."
            case .done:
                return "Successfully done"
            case .fail(let error):
                return "Failed with error: \(error.localizedDescription)"
            }
        }
    }
}
