//
//  HybinProfileDetailView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/23/26.
//

import SwiftUI

struct HybinProfileDetailView: View{
    @ObservedObject var homeVM: HybinHomeViewModel
    let size: CGSize
    let screenWidth : CGFloat
    
    var body: some View{
        if let user = homeVM.currentUser{
            ZStack{
                Image("profileImageSample1")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .clipped()
                    .frame(maxWidth: screenWidth , alignment: .center)
                    .opacity(0.1)
                ScrollView{
                    VStack{
                        Image("profileImageSample1")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: size.width, height: size.height)
                            .clipped()
                        VStack{
                            Text(user.bio)
                        }
                        VStack{
                            Text(user.name)
                        }
                        VStack(alignment: .leading, spacing: 20) {
                            Text("상세 프로필").font(.title).bold()
                            ForEach(0..<10) { i in
                                Text("관심사. \(i)")
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(10)
                            }
                        }
                    }
                }
            }
        }
    }
}
