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
    let safeArea: EdgeInsets
    
    var body: some View{
        if let user = homeVM.currentUser{
            ZStack{
                ScrollView{
                    VStack{
                        Image(user.profileImageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: size.width - 40 , height: 400)
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
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .shadow(color: .black.opacity(0.2), radius: 20, x: 0 , y:10)
                .padding(.horizontal, 20)
                .padding(.top, safeArea.top + 45)
                .padding(.bottom, safeArea.bottom + 40)
            }
        }
    }
}
