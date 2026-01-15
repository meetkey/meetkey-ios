//
//  HybinHomeView.swift
//
//
//  Created by 전효빈 on 1/15/26.
//

//피그마 홈 뷰 제작
import SwiftUI

struct HybinHomeView: View {
    @State private var users: [String] = [
        "One", "Two", "Three", "Four", "Five",
    ]
    @State private var currentIndex: Int = 0
    @State private var safeBadge = "gold"

    @State private var offset: CGSize = .zero

    @State private var isProfileDetailPresented: Bool = false
    @State private var isMatchingPresented: Bool = false

    var body: some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width * 0.76
            let imageHeight = imageWidth * (536.0 / 304.0)
            let imageSize = CGSize(width: imageWidth, height: imageHeight)

            ZStack {

                VStack {

                    Header

                    Spacer()

                    ZStack(alignment: .bottom) {

                        HybinProfileSectionView(
                            size: imageSize,
                            name: users[currentIndex],
                            badge: safeBadge
                        )
                        .offset(x: offset.width, y: offset.height * 0.1)
                        .gesture(profileDragGesture)
                        .onTapGesture {
                            isProfileDetailPresented = true
                        }

                        likeButton
                            .offset(y: imageHeight * 0.01)
                    }
                    .frame(width: imageWidth, height: imageHeight)
                    .sheet(isPresented: $isProfileDetailPresented) {
                        ProfileDetailView()
                    }
                    .fullScreenCover(isPresented: $isMatchingPresented) {
                        MatchingView {
                            withAnimation(.spring()) {
                                offset = .zero
                            }
                        }
                    }

                    Spacer()
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

    // 2.다음 유저로 넘어가는 로직
    private func goToNextUser() {
        offset = .zero

        currentIndex += 1

    }

    // 3. 종료 로직만 따로 메서드로 분리
    private func handleDragEnded(gesture: _ChangedGesture<DragGesture>.Value) {
        let translation = gesture.translation.width
        if translation > 150 {
            // 오른쪽으로 던짐 -> 매칭 화면 호출
            withAnimation(.spring()) {
                offset.width = 1000

            }
            isMatchingPresented = true
        } else if translation < -150 {
            // 다음 유저로 전환
            withAnimation(.spring()) {
                offset.width = -1000
            }
            goToNextUser()
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
                goToNextUser()
            } label: {
                Text("unlike")
                    .foregroundStyle(Color.orange)
            }
            Spacer()
            Button {
                withAnimation(.spring()) {
                    offset.width = 1000
                }
                isMatchingPresented = true

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

#Preview {
    HybinHomeView()
}
