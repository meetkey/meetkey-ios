//
//  HybinReportMenuView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/30/26.
//

import SwiftUI

struct HybinReportMenuView: View {
    @ObservedObject var homeVM: HybinHomeViewModel
    let user: User
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            VStack(spacing: 0) {
                // 상단 프로필 영역
                VStack(spacing: 12) {
                    Image(user.profileImageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                    
                    HStack(spacing: 4) {
                        Text(user.name)
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.yellow)
                    }
                }
                .padding(.vertical, 25)
                
                Divider()
                
                // 메뉴 버튼들
                menuButton(title: "프로필 보기", icon: "person", color: .black) {
                    // 프로필 보기 액션
                }
                
                Divider().padding(.horizontal, 20)
                
                menuButton(title: "차단하기", icon: "xmark.circle", color: .black) {
                    // 차단 액션
                }
                
                Divider().padding(.horizontal, 20)
                
                menuButton(title: "신고하기", icon: "exclamationmark.triangle", color: .red) {
                    // 신고 액션
                }
            }
            .background(Color.white)
            .cornerRadius(30, corners: [.topLeft, .topRight]) // 상단만 둥글게
        }
        .ignoresSafeArea()
        .background(
            Color.black.opacity(0.4)
                .onTapGesture { homeVM.showReportMenu = false } // 배경 누르면 닫힘
        )
    }
    
    private func menuButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
            homeVM.showReportMenu = false
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                    .font(.system(size: 16))
                Spacer()
            }
            .foregroundColor(color)
            .padding(.horizontal, 25)
            .padding(.vertical, 20)
        }
    }
}
