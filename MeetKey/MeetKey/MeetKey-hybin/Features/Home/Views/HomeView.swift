//
//  HybinHomeView.swift
//
//
//  Created by 전효빈 on 1/15/26.
//

//피그마 홈 뷰 제작
import SwiftUI

struct HomeView: View {

    @ObservedObject var homeVM: HomeViewModel

    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let safeArea = geometry.safeAreaInsets
            
            ZStack(alignment: .top) {
                backgroundImageView(size: screenSize)  // 배경 분리

                if homeVM.status == .finished {
                    FinishedMatchView(
                        size: screenSize,
                        safeArea: safeArea,
                        action: homeVM.resetDiscovery
                    )
                } else {
                    contentStack(size: screenSize, safeArea: safeArea)  // 카드/디테일 분리
                }
                
                headerView
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .task { await homeVM.fetchUserAsync() }
        //매칭뷰 호출
        .fullScreenCover(isPresented: $homeVM.isMatchViewPresented) {
            MatchingView(homeVM: homeVM)
        }
        // 필터뷰 호출
        .fullScreenCover(isPresented: $homeVM.isFilterViewPresented) {
            FilterView(homeVM: homeVM) { offset = .zero }
        }
    }
}

//MARK: - Contents
extension HomeView {

    //-----BackGround
    @ViewBuilder
    private func backgroundImageView(size: CGSize) -> some View {
        if let user = homeVM.currentUser {
            Image(user.profileImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: size.width, height: size.height)
                .clipped()
                .opacity(0.4)
        } else {
            Color.black.opacity(0.1).ignoresSafeArea()
        }
    }

    //-----Content
    @ViewBuilder
    private func contentStack(size: CGSize, safeArea: EdgeInsets) -> some View {
        if !homeVM.isDetailViewPresented {
            ZStack {
                if let user = homeVM.currentUser {
                    ProfileSectionView(size: size, user: user)
                        .offset(x: offset.width, y: offset.height * 0.1)
                        .gesture(profileDragGesture)
                        .onTapGesture { homeVM.presentDetailView() }
                }
                likeButtonSection  // 버튼 섹션 분리
                    .padding(.horizontal, 20)
            }
        } else {
            HomeProfileDetailView(
                homeVM: homeVM,
                size: size,
                safeArea: safeArea
            )
        }
    }

    //------Header
    private var headerView: some View {
        HeaderOverlay(
            state: homeVM.isDetailViewPresented ? .homeDetail : .home,
            user: homeVM.me,
            reportVM: homeVM.reportVM,
            onLeftAction: {homeVM.dismissDetailView()},
            onRightAction: {homeVM.presentFilterView()},
            onDetailAction: { }
        )
        .zIndex(1)
    }
}

//MARK: - 버튼 컴포넌트
extension HomeView {
    private var likeButtonSection: some View {
        HStack {
            actionButton(
                imageName: "btn_skip",
                isLike: false
            )
            Spacer()
            actionButton(
                imageName: "btn_like",
                isLike: true
            )
        }
    }

    private func actionButton(
        imageName: String,
        isLike: Bool
    ) -> some View {
        Button {
            triggerAction(isLike: isLike)
        } label: {
            Image(imageName)
                .frame(width: 64, height: 64)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
    }
}

// MARK: - Gestures & Actions
extension HomeView {
    private var profileDragGesture: some Gesture {
        DragGesture()
            .onChanged { offset = $0.translation }
            .onEnded { gesture in
                let translation = gesture.translation.width
                if translation > 150 {
                    triggerAction(isLike: true)
                } else if translation < -150 {
                    triggerAction(isLike: false)
                } else {
                    withAnimation(.spring()) { offset = .zero }
                }
            }
    }

    private func triggerAction(isLike: Bool) {
        withAnimation(.spring()) {
            offset.width = isLike ? 1000 : -1000
        }

        Task {
            if isLike {
                await homeVM.handleLikeAction()
            } else {
                homeVM.handleSkipAction()
            }
            offset = .zero
        }
    }
}
