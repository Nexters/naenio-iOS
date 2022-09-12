//
//  NaenioApp.swift
//  Naenio
//
//  Created by 이영빈 on 2022/07/09.
//

import SwiftUI
import KakaoSDKAuth
import KakaoSDKCommon

@main
struct NaenioApp: App {
    @StateObject var networkMonitor = NetworkStatusMonitor()
    @ObservedObject var tokenManager = TokenManager.shared
    @ObservedObject var userManager = UserManager.shared
    
    @State var isLinkOpened = false
    @State var arrivedPostId: Int = 0 {
        didSet {
            isLinkOpened = true
        }
    }
    
    init() {
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: KeyValue.kakaoAPIkey)
        
        if tokenManager.isTokenAvailable, let token = tokenManager.accessToken {
            userManager.updateUserData(with: token)
        }
        
        print(tokenManager.accessToken as Any)
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack(alignment: .top) {
                if networkMonitor.status == .disconnected {
                    offlineIndicator
                }
                
                if tokenManager.accessToken == nil {
                    LoginView()
                        .environmentObject(tokenManager)
                        .environmentObject(userManager)
                } else if userManager.user?.nickname == nil,
                          userManager.status == .fetched {
                    OnboardingView()
                        .environmentObject(userManager)
                } else if tokenManager.accessToken != nil,
                          userManager.user != nil,
                          userManager.status == .fetched {
                    NavigationView {
                        MainView()
                            .environmentObject(userManager)
                            .onOpenURL { url in
                                guard let postId = handleUrl(url) else {
                                    return
                                }
                                
                                self.arrivedPostId = postId
                            }
                            .background(
                                NavigationLink(destination:
                                                OpenedByLinkFullView(postId: arrivedPostId, showCommentFirst: false)
                                    .environmentObject(userManager),
                                               isActive: $isLinkOpened) {
                                                   EmptyView()
                                               }
                            )
                            .navigationBarHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
                    }
                } else {
                    Color.background
                        .ignoresSafeArea()
                    VStack {
                        Spacer()
                        
                        if networkMonitor.status == .disconnected {
                            EmptyResultView(description: "로그인 중 오류가 발생했습니다. \n네트워크 상태를 확인해주세요.")
                                .onDisappear {
                                    if tokenManager.isTokenAvailable, let token = tokenManager.accessToken {
                                        userManager.updateUserData(with: token)
                                    }
                                }
                        } else {
                            
                        }
                        
                        Spacer()
                    }
                }
            }
        }
    }
    
    var offlineIndicator: some View {
        HStack{
            Spacer()
            Text("인터넷 연결 끊김")
                .font(.medium(size: 13))
            Spacer()
        }
        .fillHorizontal()
        .frame(height: 30)
        .background(Color.naenioGray.ignoresSafeArea())
        .zIndex(1)
    }
}

// Maybe replaced later by URL handler class
func handleUrl(_ url: URL) -> Int? {
    print("URL received: \(url)")
    guard let link = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let linkItem = link.queryItems?.filter({ $0.name == "link" }).last?.value,
          let postQuery = linkItem.components(separatedBy: "//").last,
          let postId = postQuery.split(separator: "=").last
    else {
        return nil
    }
    
    return Int(postId)
}
