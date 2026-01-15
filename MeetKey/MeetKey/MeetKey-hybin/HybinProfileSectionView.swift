//
//  HybinProfileSectionView.swift
//  
//
//  Created by 전효빈 on 1/15/26.
//

import SwiftUI

struct HybinProfileSectionView: View {
    let size: CGSize
    let name: String
    let badge : String
    var body: some View {
        ZStack(alignment: .top) {
            

            Image("profileImageSample1")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
            
            Spacer()
            VStack{
                HStack{
                    Spacer()
                    Text(badge)
                        .foregroundStyle(Color.orange)
                }
                Spacer()
                Text(name)
                    .font(.title)
                    .foregroundStyle(Color.white)
                
            }
            .frame(width:size.width,height:size.height * 0.7)
        }
    }
}
