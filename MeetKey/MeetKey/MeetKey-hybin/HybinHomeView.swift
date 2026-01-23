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

    @State private var isProfileDetailPresented: Bool = false
    @State private var isDetailExpanded: Bool = false
    //    @State private var isMatchingPresented: Bool = false
//    @State private var isFilterPresented: Bool = false

//    var body: some View {
//        GeometryReader { geometry in
//            let imageWidth = geometry.size.width * 0.76
//            let imageHeight = imageWidth * (536.0 / 304.0)
//            let imageSize = CGSize(width: imageWidth, height: imageHeight)
////            let screenWidth = geometry.size.width
//
//            ZStack {
//                VStack {
//                    Header
//                    Spacer()
//                    ZStack(alignment: .bottom) {
//                        if let user = homeVM.currentUser {
//                            HybinProfileSectionView(
//                                size: imageSize,
//                                user: user
//                            )
//                            .offset(x: offset.width, y: offset.height * 0.1)
//                            .gesture(profileDragGesture)
//                            .onTapGesture {
//                                isProfileDetailPresented = true
//                            }
//                        }
//
//                        likeButton
//                            .offset(y: imageHeight * 0.01)
//                    }
//                    .frame(width: imageWidth, height: imageHeight)
//                    .sheet(isPresented: $isProfileDetailPresented) {
//                        ProfileDetailView()
//                    }
//                    .fullScreenCover(isPresented: $homeVM.showMatchView) {
//                        HybinMatchingView(homeVM: homeVM) {
//                            withAnimation(.spring()) {
//                                offset = .zero
//                            }
//                        }
//                    }
//
//                    Spacer()
//                }
//                .fullScreenCover(isPresented: $homeVM.showFilter) {
//                    HybinFilterView(homeVM: homeVM) {
//                        withAnimation(.spring()) {
//                            offset = .zero
//                        }
//                    }
//                }
//            }
//        }
//    }

    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width * 0.76
            let imageHeight = imageWidth * (536.0 / 304.0)
            let imageSize = CGSize(width: imageWidth, height: imageHeight)
//            let screenWidth = geometry.size.width

            ZStack {
                if !homeVM.showDetailExpander{
                    VStack {
                        Header
                        Spacer()
                        ZStack(alignment: .bottom) {
                            if let user = homeVM.currentUser {
                                HybinProfileSectionView(
                                    size: imageSize,
                                    user: user
                                )
                                .offset(x: offset.width, y: offset.height * 0.1)
                                .gesture(profileDragGesture)
                                .onTapGesture {
                                    homeVM.goDetail()
                                }
                            }
                            
                            likeButton
                                .offset(y: imageHeight * 0.01)
                        }
                        .frame(width: imageWidth, height: imageHeight)
                        
                        .fullScreenCover(isPresented: $homeVM.showMatchView) {
                            HybinMatchingView(homeVM: homeVM) {
                                withAnimation(.spring()) {
                                    offset = .zero
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .fullScreenCover(isPresented: $homeVM.showFilter) {
                        HybinFilterView(homeVM: homeVM) {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }
                } else {
                    ScrollView{
                        VStack{
                            Text("프로필 디테일뷰를 위한 스크롤 뷰입니다")
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        homeVM.goHomefromDetail()
                                    }
                                }
                            VStack(alignment: .leading, spacing: 15) {
                                Text(homeVM.currentUser!.name)
                                    .font(.largeTitle).bold()
                                
                                Text(homeVM.currentUser!.bio)
                                    .font(.body)
                                    .lineSpacing(10)
                                
                                // 스크롤 확인용 더미 텍스트
                                ForEach(0..<10) { i in
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 100)
                                        .overlay(Text("추가 정보 영역 \(i)"))
                                }
                            }
                            .padding()
                        }
                    }
                    .transition(.opacity)
                }
            }
        }
    }

    //MARK: - Header (Logo and Filter)
    private var Header: some View {
        HStack {
            appLogoTitleView
            Spacer()
            filterButton
        }
    }

    // MARK: - 앱 로고 타이틀 뷰
    private var appLogoTitleView: some View {
        HStack {
            Text("logo")
        }
    }

    //MARK: -필터 버튼
    private var filterButton: some View {

        Button(action: {
            print("filter")
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                homeVM.didSelectFilter()
            }
        }) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 20))
                .foregroundStyle(Color.black)
        }
    }

    //MARK: - 제스처 메서드

    //1. 제스처 본체 분리
    var profileDragGesture: some Gesture {
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
                    offset.width = -1000
                }
                homeVM.didSelectUnlike()
                offset = .zero
            } label: {
                Text("unlike")
                    .foregroundStyle(Color.orange)
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    offset.width = 1000
                }
                homeVM.didSelectLike()

            } label: {
                Text("match")
                    .foregroundStyle(Color.orange)
            }
        }
    }
}
//MARK: -프로필 디테일 뷰
struct ProfileDetailView: View {
    var body: some View {
        VStack {
            Capsule()  // 시트 상단 바 느낌
                .frame(width: 40, height: 6)
                .foregroundColor(.gray.opacity(0.5))
                .padding(.top)
            Text("profile detail")
            Spacer()
        }
    }
}
