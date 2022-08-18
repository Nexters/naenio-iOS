//
//  ProfileImageSelectionView.swift
//  Naenio
//
//  Created by YoungBin Lee on 2022/08/16.
//

import SwiftUI

struct ProfileImageSelectionSheetView: View {
    @Binding var index: Int
    
    let columns: [GridItem] = [
        GridItem(.flexible(maximum: 85), spacing: 35),
        GridItem(.flexible(maximum: 85), spacing: 35),
        GridItem(.flexible(maximum: 85), spacing: 35)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 35) {
            ForEach((0..<ProfileImages.count), id: \.self) { index in
                ProfileImages.getImage(of: index) // Preset image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 85, height: 85)
                    .onTapGesture {
                        self.index = index
                    }
            }
        }
        .padding(.bottom, 30)
    }
}