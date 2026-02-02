//
//  HybinMatchingView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/23/26.
//

import SwiftUI

struct MatchingView: View {

    @ObservedObject var homeVM: HomeViewModel

    @State private var messageText: String = ""

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let safeArea = geometry.safeAreaInsets

            ZStack(alignment: .top) {

                VStack {
                    Spacer()

                    VStack {
                        Image("profileSampleImage1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                        VStack {
                            Text("soulMate")
                            Text("yourFriends")
                        }
                    }
                    Spacer()
                    chatInputSection
                }
                .frame(width: screenSize.width, height: screenSize.height)

                HeaderOverlay(
                    state: .chat,
                    safeArea: safeArea,
                    user: homeVM.currentUser ?? homeVM.me,
                    homeVM: homeVM,
                    onBackAction: homeVM.dismissMatchView,
                    onFilterAction: homeVM.reportVM.handleReportMenuTap
                ).zIndex(1)

            }
            .ignoresSafeArea(.all, edges: .bottom)
            .sheet(
                isPresented: Binding(
                    get: {
                        homeVM.reportVM.currentReportStep != .none
                            && homeVM.reportVM.currentReportStep != .main
                    },
                    set: { if !$0 { homeVM.reportVM.closeReportMenu() } }
                )
            ) {
                ReportSelectionView(
                    reportVM: homeVM.reportVM,
                    targetUser: homeVM.currentUser ?? User.mockData[0]
                )
                .presentationDetents([.medium])  // 피그마처럼 중간 높이 설정
                //                    .presentationDragIndicator(.visible)
            }
        }
    }
}

extension MatchingView {
    private var chatInputSection: some View {
        VStack(alignment: .leading, spacing: 16) {

            // 대화 주제 추천 버튼
            Button(action: { /* 주제 추천 로직 */  }) {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 12))
                    Text("대화 주제 추천 받기 5/5")
                        .font(.system(size: 13, weight: .medium))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundColor(.orange)
                .overlay(
                    Capsule().stroke(Color.orange, lineWidth: 1)
                )
            }
            .padding(.leading, 20)

            // 입력 필드와 전송 버튼
            HStack(spacing: 12) {
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }

                TextField("Type a message", text: $messageText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(25)

                Button(action: { /* 메시지 전송 */  }) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.orange)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 20)
        }
        .background(Color.white)
    }
}
