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
    @State private var isMatchingPresented: Bool = false
    @State private var isFilterPresented: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width * 0.76
            let imageHeight = imageWidth * (536.0 / 304.0)
            let imageSize = CGSize(width: imageWidth, height: imageHeight)
            let screenWidth = geometry.size.width

            ZStack {

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
                                isProfileDetailPresented = true
                            }
                        }
                        

                        likeButton
                            .offset(y: imageHeight * 0.01)
                    }
                    .frame(width: imageWidth, height: imageHeight)
                    .sheet(isPresented: $isProfileDetailPresented) {
                        ProfileDetailView()
                    }
                    .fullScreenCover(isPresented: $homeVM.showMatchView) {
                        MatchingView {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }

                    Spacer()
                }
                .blur(radius: isFilterPresented ? 3 : 0)
                .disabled(isFilterPresented)
                
                if isFilterPresented {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { isFilterPresented = false }
                        }
                }
                FilterSideView()
                    .frame(width: imageWidth)
                    .offset(x: isFilterPresented ? screenWidth - imageWidth : screenWidth)
                    .animation(.spring(), value: isFilterPresented)

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
                isFilterPresented.toggle()
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

//MARK: - 매칭 뷰
struct MatchingView: View {
    @Environment(\.dismiss) var dismiss
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            VStack {
                Button(action: {
                    onDismiss()
                    dismiss()  //
                }) {
                    Text("계속 탐색하기")
                        .font(.headline)
                        .foregroundStyle(Color.black)
                        .padding()
                        .frame(width: 250)
                }
                Color.pink.opacity(0.1)
                Text("Matching View")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 필터뷰
struct FilterSideView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("필터 설정")
                .font(.headline)
                .padding(.top, 60)

            Divider()

            // 간단한 필터 항목들
            VStack(alignment: .leading) {
                Text("거리 범위").font(.caption).foregroundColor(.gray)
                Text("20km 이내").bold()
            }

            VStack(alignment: .leading) {
                Text("나이대").font(.caption).foregroundColor(.gray)
                Text("24세 - 30세").bold()
            }

            Spacer()

            Button("적용하기") {
                // 적용 로직
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}
