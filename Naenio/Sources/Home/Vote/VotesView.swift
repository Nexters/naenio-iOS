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
            VStack(spacing: 18) { // ???: 어느 미래에 선택지가 2개가 아닌 1개만 들어오는 케이스를 대비할 필요도 있음
                VoteButton(type: .choiceA, isOpened: self.isOpened, choice: choices[0]) {
                    sourceObject.vote(index: self.index, sequence: 0)
                }
                
                VoteButton(type: .choiceB, isOpened: self.isOpened, choice: choices[1]) {
                    sourceObject.vote(index: self.index, sequence: 1)
                }
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
