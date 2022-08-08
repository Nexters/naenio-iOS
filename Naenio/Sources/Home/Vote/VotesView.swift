//
//  VoteView.swift
//  Naenio
//
//  Created by 이영빈 on 2022/08/06.
//

import SwiftUI

struct VotesView: View {
    @ObservedObject var viewModel: VotesViewModel
    @EnvironmentObject var sourceObject: HomeViewModel

    let index: Int
    let choices: [Post.Choice]
    var isOpened: Bool {
        return !choices
            .filter { $0.isVoted }
            .isEmpty
    }

    var body: some View {
        ZStack {
            // TODO: 추가적인 작업 필요함. 지금은 액션 구현만 되어있는데 정확한 동작은 따로 브랜치 만들어서 작업할 예정
            // (일단 싱크 위해서 머지만 해놓고)
            VStack(spacing: 18) { // ???: 어느 미래에 선택지가 2개가 아닌 1개만 들어오는 케이스를 대비할 필요도 있음
                VoteButton(type: .choiceA, isOpened: self.isOpened, choice: choices.first) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        sourceObject.vote(index: self.index, sequence: 0)
                    }
                }
//                .frame(height: 72)
                
                VoteButton(type: .choiceB, isOpened: self.isOpened, choice: choices.last) {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        sourceObject.vote(index: self.index, sequence: 1)
                    }
                }
//                .frame(height: 72)
            }
            
            Text("VS")
                .font(.engSemiBold(size: 16)) // ???: 제플린 따라서 18로 넣으면 잘 안맞음(https://zpl.io/dxjxvn7)
                .background(
                    Circle().fill(Color.white)
                        .frame(width: 34, height: 34)
                )
        }
    }
    
    init(index: Int, choices: [Post.Choice]) {
        self.index = index
        self.choices = choices
        self.viewModel = VotesViewModel()
    }
}
