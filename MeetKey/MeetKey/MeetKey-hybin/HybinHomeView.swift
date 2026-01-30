//
//  HybinHomeView.swift
//
//
//  Created by 전효빈 on 1/15/26.
//

//피그마 홈 뷰 제작
import SwiftUI

struct HybinHomeView: View {

    @ObservedObject var homeVM: HybinHomeViewModel

    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let screenSize = geometry.size
            let safeArea = geometry.safeAreaInsets
            //MARK: - 배경처리
            ZStack(alignment: .top) {
                if let user = homeVM.currentUser {
                    Image(user.profileImageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: screenSize.width,
                            height: screenSize.height
                        )
                        .clipped()
                        .opacity(0.4)
                } else {
                    Color.black.ignoresSafeArea()
                        .opacity(0.1)
                }
                //MARK: - 마지막 인덱스 처리
                if homeVM.hasReachedLimit {
                    //HybinFinishedMatchView로 처리할거임
                    VStack {
                        Button {
                            homeVM.resetDiscovery()
                        } label: {
                            Text("처음으로")
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // MARK: - 콘텐츠
                    Group {
                        if !homeVM.showDetailExpander {
                            ZStack {
                                if let user = homeVM.currentUser {
                                    HybinProfileSectionView(
                                        size: screenSize,
                                        user: user
                                    )
                                    .offset(
                                        x: offset.width,
                                        y: offset.height * 0.1
                                    )
                                    .gesture(profileDragGesture)
                                    .onTapGesture { homeVM.didTapDetail() }
                                }
                                likeButton
                                    .padding(.horizontal, 20)
                            }
                        } else {
                            HybinProfileDetailView(
                                homeVM: homeVM,
                                size: screenSize,
                                safeArea: safeArea
                            )
                        }
                    }
                }
                // MARK: - 헤더
                if !homeVM.showDetailExpander {
                    HeaderOverlay(
                        state: .home,
                        safeArea: safeArea,
                        user: homeVM.me,
                        onBackAction: { homeVM.didTapBackFromDetail() },
                        onFilterAction: { homeVM.didSelectFilter() }
                    ).zIndex(1)
                } else {
                    HeaderOverlay(
                        state: .detail,
                        safeArea: safeArea,
                        user: homeVM.me,
                        onBackAction: {
                            homeVM.didTapBackFromDetail()
                        },
                        onFilterAction: {
                            homeVM.didSelectFilter()
                        }
                    )
                    .zIndex(1)  //항상 최상단
                }
            }
            // 공통 모달 처리
            .fullScreenCover(isPresented: $homeVM.showMatchView) {
                HybinMatchingView(homeVM: homeVM) { offset = .zero }
            }
            .fullScreenCover(isPresented: $homeVM.showFilterView) {
                HybinFilterView(homeVM: homeVM) { offset = .zero }
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }

    //MARK: - 제스처 메서드

    //1. 제스처 본체 분리
    private var profileDragGesture: some Gesture {
        DragGesture()
            .onChanged { gesture in
                // 드래그 중 위치 업데이트
                offset = gesture.translation
            }
            .onEnded { gesture in
                // 드래그 종료 시 로직 실행
                handleDragEnded(gesture: gesture)
            }
    }

    // 3. 종료 로직만 따로 메서드로 분리
    private func handleDragEnded(gesture: _ChangedGesture<DragGesture>.Value) {
        let translation = gesture.translation.width
        if translation > 150 {
            // 오른쪽으로 던짐 -> 매칭 화면 호출
            withAnimation(.spring()) {
                offset.width = 1000
            }
            offset = .zero
            homeVM.didSelectLike()

        } else if translation < -150 {
            // 다음 유저로 전환
            withAnimation(.spring()) {
                offset.width = -1000
            }
            offset = .zero
            homeVM.didSelectUnlike()
        } else {
            withAnimation(.spring()) {
                offset = .zero
            }
        }
    }

    // MARK: - 관심 버튼
    private var likeButton: some View {
        HStack {
            Button {
                withAnimation(.spring()) {
                    offset.width = -500
                }
                homeVM.didSelectUnlike()
                offset = .zero
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.white)
                    .frame(width: 64, height: 64)
                    .background(Color.black.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    offset.width = 500
                }
                homeVM.didSelectLike()

            } label: {
                Image(systemName: "heart.fill")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.orange)
                    .frame(width: 64, height: 64)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            }
        }
    }
}
