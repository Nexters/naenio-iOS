//
//  FullViewModel.swift
//  Naenio
//
//  Created by YoungBin Lee on 2022/08/05.
//

import SwiftUI
import RxSwift

class FullViewModel: ObservableObject {
    @Published var status: NetworkStatus<WorkType> = .waiting
    @Published var post: Post = MockPostGenerator.generate(sortType: .wrote)
    
    private var bag = DisposeBag()
    private let serialQueue = SerialDispatchQueueScheduler.init(qos: .userInitiated)
    
    func getOnePost(with postId: Int) {
        self.status = .inProgress
        
        RequestService<SinglePostResponseModel>
            .request(api: .getSinglePost(SinglePostRequestInformation(id: postId)))
            .subscribe(on: serialQueue)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] postResponse in
                    guard let self = self else { return }
                    
                    self.post = postResponse.toPost()
                    self.status = .done(result: .singlePost)
                }, onFailure: { [weak self] error in
                    guard let self = self else { return }
                    
                    print("Failed with error: \(error.localizedDescription)")
                    self.status = .fail(with: error)
                })
            .disposed(by: bag)
    }
    
    func getImage(of index: Int) -> Image {
        return ProfileImages.getImage(of: index)
    }
    
    func report(authorId: Int, type: CommentType) {
        status = .inProgress
        
        ReportManager.report(authorId: authorId, type: type)
            .subscribe(on: self.serialQueue)
            .observe(on: MainScheduler.instance)
            .subscribe(
                onSuccess: { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.status = .done(result: .report)
                }, onFailure: { [weak self] error in
                    guard let self = self else { return }
                    
                    self.status = .fail(with: error)
                })
            .disposed(by: bag)
    }

    init() {
//        print(TokenManager().loadToken())
    }
}

extension FullViewModel {
    enum WorkType { // FIXME:
        case report
        case singlePost
    }
}
