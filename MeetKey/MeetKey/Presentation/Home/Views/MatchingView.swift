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

                backgroundSection(size: screenSize)

                if homeVM.reportVM.isReportMenuPresented {
                    closeOverlay
                }

                VStack {
                    Spacer()
                    ChatInputSection(messageText: $messageText)
                        .padding(.bottom, safeArea.bottom)
                }

                HeaderOverlay(
                    state: .chat,
                    user: homeVM.currentUser ?? homeVM.me,
                    reportVM: homeVM.reportVM,
                    onLeftAction: homeVM.dismissMatchView,
                    onRightAction: homeVM.reportVM.handleReportMenuTap,
                    onDetailAction: homeVM.presentDetailView
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
                .presentationDetents([.medium])
            }
        }

    }

    private func backgroundSection(size: CGSize) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image("profileImageSample1")  // 나중에 실제 데이터로 교체 가능
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                VStack {
                    Text("soulMate").font(.headline)
                    Text("yourFriends").font(.subheadline).foregroundColor(
                        .gray
                    )
                }
            }
            Spacer()
        }
        .frame(width: size.width, height: size.height)
    }

    //클릭 시 오버레이를 닫게 하기 위한 레이어
    private var closeOverlay: some View {
        Color.black.opacity(0.001)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation { homeVM.reportVM.closeReportMenu() }
            }
    }
}
