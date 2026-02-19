//
//  HybinMatchingView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/23/26.
//

import SwiftUI

struct MatchingView: View {
    @EnvironmentObject var profileVM: MyProfileViewModel


    @ObservedObject var homeVM: HomeViewModel

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let safeArea = geometry.safeAreaInsets
            let headerHeight: CGFloat = 125

            ZStack(alignment: .top) {

                if !homeVM.isChattingStarted {
                    backgroundSection(size: screenSize)
                }

                VStack(spacing: 0) {
                    if homeVM.isChattingStarted {
                        Spacer().frame(height: headerHeight)

                        ScrollViewReader { proxy in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(
                                        homeVM.matchChatMessages,
                                        id: \.messageId
                                    ) { msg in
                                        MatchMessageBubble(message: msg)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 20)
                            }
                            .onChange(of: homeVM.matchChatMessages.count) {
                                oldValue,
                                newValue in
                                withAnimation {
                                    if let lastId = homeVM.matchChatMessages
                                        .last?.messageId
                                    {
                                        proxy.scrollTo(lastId, anchor: .bottom)
                                    }
                                }
                            }
                        }
                    } else {
                        Spacer()
                    }

                    ChatInputSection(
                        messageText: $homeVM.matchMessageText,
                        onSend: {
                            Task {
                                await homeVM.sendInitialMatchMessage()
                            }
                        }
                    )
                    .padding(.bottom, safeArea.bottom)
                }

                if homeVM.reportVM.isReportMenuPresented {
                    closeOverlay
                }

                VStack {
                    Spacer()
                    ChatInputSection(
                        messageText: $homeVM.matchMessageText,
                        onSend: {
                            Task {
                                await homeVM.sendInitialMatchMessage()
                            }
                        }
                    )
                    .padding(.bottom, safeArea.bottom)
                }

                HeaderOverlay(
                    state: .chat,
                    user: (homeVM.currentUser ?? homeVM.profileVM.user) ?? User.me,
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
                    targetUser: homeVM.currentUser ?? User.me
                )
                .presentationBackground(Color.background1)
                .presentationDetents([
                    homeVM.reportVM.currentReportStep == .reportCase
                        ? .height(500)
                        : homeVM.reportVM.currentReportStep == .reportReason
                            ? .height(500) : .medium
                ])
                .animation(
                    .spring(response: 0.4, dampingFraction: 0.8),
                    value: homeVM.reportVM.currentReportStep
                )
            }
        }
    }

    private func backgroundSection(size: CGSize) -> some View {
        VStack {
            Spacer()
            VStack(spacing: 12) {
                Image("img_meetkey_matched")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140, height: 140)

                VStack(alignment: .center) {
                    Text("소울 메이트 발견!")
                        .font(.meetKey(.title4))
                        .foregroundStyle(Color.text2)
                    Text("회원님과 잘 맞을 것 같은 친구를 발견했어요.")
                        .font(.meetKey(.body5))
                        .foregroundStyle(Color.text4)
                    Text("바로 대화를 시작해보세요!")
                        .font(.meetKey(.body5))
                        .foregroundStyle(Color.text4)
                }
            }
            Spacer()
        }
        .frame(width: size.width, height: size.height)
    }

    private var closeOverlay: some View {
        Color.black.opacity(0.001)
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation { homeVM.reportVM.closeReportMenu() }
            }
    }
}

struct MatchMessageBubble: View {
    let message: ChatMessageDTO

    var body: some View {
        HStack {
            Spacer()
            Text((message.content ?? "").unquoted)
                .font(.system(size: 15))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(Color.white)
                .background(Color.orange)
                .clipShape(
                    MyRoundedCorner(
                        radius: 12,
                        corners: [.topLeft, .bottomLeft, .bottomRight]
                    )
                )
        }
    }
}
