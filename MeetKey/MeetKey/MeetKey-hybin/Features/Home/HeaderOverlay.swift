//
//  HeaderOverlay.swift
//  MeetKey
//
//  Created by 전효빈 on 1/26/26.
//

import SwiftUI

enum HeaderType {
    case home
    case chat
    case detail
}
//MARK: -- ## HeaderOverlay는 공용으로 써야할거같으니 분리 해야함!!!!!!
//TODO: ##### 꼭 의존성 분리하자!!!!!!!!!!!!!
struct HeaderOverlay: View {
    let state: HeaderType
    let safeArea: EdgeInsets
    let user: User

    @ObservedObject var homeVM: HomeViewModel


    var onBackAction: () -> Void
    var onFilterAction: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            // 1. 배경 처리


            // 2. 버튼 및 콘텐츠 레이어
            VStack {
                HStack(alignment: .center) {

                    Group {
                        switch state {
                        case .home:
                            homeProfileCircle
                        case .detail:
                            backButton(icon: "arrow.left")
                        case .chat:
                            backButton(icon: "xmark")
                        }
                    }
                    .frame(width: 40, height: 40)  // 크기 통일

                    // 중앙 텍스트 (홈 모드일 때만 보임)
                    if state == .home {
                        homeHeaderText
                            .padding(.leading, 8)
                    } else if state == .chat {

                        Spacer()
                        Text(user.name)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }

                    Spacer()

                    // 오른쪽 버튼 영역
                    rightSideButton
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .padding(.top, 16)

                if homeVM.reportVM.isReportMenuPresented {
                    reportMenuList
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea(edges: .top)
            )
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - 서브 컴포넌트
extension HeaderOverlay {

    // 공통 버튼 스타일 (상세 뒤로가기 & 채팅 X버튼)
    private func backButton(icon: String) -> some View {
        Button(action: { onBackAction() }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .frame(width: 40, height: 40)  // Circle 크기와 동일하게
                .background(Color.white.opacity(0.8))
                .clipShape(Circle())
        }
    }

    // 홈 프로필 서클
    private var homeProfileCircle: some View {
        Circle()
            .frame(width: 40, height: 40)
            .foregroundColor(.gray.opacity(0.3))
            .overlay(Text(String(user.name.prefix(1))).foregroundColor(.white))
    }

    // 홈 텍스트
    private var homeHeaderText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(user.name + "님,")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.7))
            Text("이런 친구는 어때요?")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // 오른쪽 버튼 분기 (필터 vs 신고)
    private var rightSideButton: some View {
        Group {
            if state == .home || state == .detail {
                FilterButton {
                    withAnimation(.spring()) { onFilterAction() }
                }
            } else if state == .chat {
                // 신고 버튼 (점 세개)
                Button(action: { onFilterAction() }) {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                }
            }
        }
    }

    // 신고 메뉴

    private var reportMenuList: some View {
        VStack {
            // 1. 화면 전환 액션
            menuItem(title: "프로필 보기", icon: "person.circle") {
                homeVM.presentDetailView()  // 기존에 만든 상세 보기 함수 호출
                homeVM.dismissMatchView()// 일단 homeDetail로 빠지기..
            }

            Divider().padding(.horizontal, 10)

            // 2. 상태값 변경 액션
            menuItem(title: "차단하기", icon: "nosign") {
                homeVM.reportVM.currentReportStep = ReportStep.block  // 차단 확인 단계로 변경
            }

            Divider().padding(.horizontal, 10)

            // 3. 복합적인 액션 (로그 찍기 + 화면 전환)
            menuItem(
                title: "신고하기",
                icon: "exclamationmark.bubble",
                isDestructive: true
            ) {
                print("신고 프로세스 시작: \(homeVM.currentUser?.name ?? "알 수 없음")")
                homeVM.reportVM.currentReportStep = ReportStep.report  // 신고 사유 선택 단계로 변경
            }

            Divider().padding(.horizontal, 10)
        }
    }

    private func menuItem(
        title: String,
        icon: String,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            withAnimation { homeVM.reportVM.isReportMenuPresented = false }
            action()
        }) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .frame(width: 24)
                Text(title)
                Spacer()
            }
            .foregroundStyle(isDestructive ? Color.red : Color.black)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
    }
}

//enum HeaderType {
//    case home  //매칭 화면 (HomeView Header)
//    case homeDetail  //홈에서 진입한 상세 프로필 (HomeProfileDetailView Header)
//    case matchingSuccess  //홈에서 LikeAction 이후 보이는 채팅방에서의 헤더
//
//    case chat  // 블루(은재)님 채팅방에 사용될 헤더
//
//    case myProfile  // 수민님의 나의 프로필 헤더
//    case opponentDetail  // 홈뷰 -> 디테일을 제외한 상대방 프로필 디테일 화면
//}
//
//struct HeaderOverlay: View {
//    let state: HeaderType
//    let user: User
//
//    var onLeftAction: () -> Void
//    var onRightAction: () -> Void
//
//    var body: some View {
//        ZStack(alignment: .bottom) {
//
//            VStack {
//                switch state {
//                case .home, .homeDetail, .opponentDetail:
//                    //                    homeHeaderLayout
//                case .myProfile:
//                    EmptyView()
//                //수민님 프로필 뷰
//                case .chat, .matchingSuccess:
//                    //                    chatHeaderLayout
//                }
//                if homeVM.reportVM.isReportMenuPresented {
//                                    reportMenuList
//                                }
//            }
//            .background(
//                RoundedRectangle(cornerRadius: 20)
//                    .fill(.ultraThinMaterial)
//                    .ignoresSafeArea(edges: .top)
//            )
//        }
//        .fixedSize(horizontal: false, vertical: true)
//    }
//}
//
////MARK: - homeHeaderView
//struct HomeHeaderView: View {
//    var state: HeaderType
//    let user: User
//    var onLeftAction: () -> Void
//    var onRightAction: () -> Void
//    //타입, 유저, 액션(왼쪽 오른쪽)
//
//    var body: some View {
//        HStack {
//            switch state {
//            case .home:
//                leftSideButton(icon: "")
//                homeHeaderText
//                rightSideButton
//            case .homeDetail:
//                leftSideButton(icon: "")
//                homeHeaderText
//                rightSideButton
//            case .opponentDetail:
//                leftSideButton(icon: "")
//                homeHeaderText
//                rightSideButton
//            case .chat, .matchingSuccess, .myProfile:
//                EmptyView()
//            }
//
//        }
//    }
//    private func leftSideButton(icon: String) -> some View {
//        Button(action: { onLeftAction() }) {
//            Image(icon)
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(.black)
//                .frame(width: 40, height: 40)  // Circle 크기와 동일하게
//                .background(Color.white.opacity(0.8))
//                .clipShape(Circle())
//        }
//    }
//
//    private var homeHeaderText: some View {
//        VStack(alignment: .leading, spacing: 2) {
//            Text(user.name + "님,")
//                .font(.system(size: 12))
//                .foregroundColor(.white.opacity(0.7))
//            Text("이런 친구는 어때요?")
//                .font(.system(size: 18, weight: .bold))
//                .foregroundColor(.white)
//        }
//    }
//
//    private var rightSideButton: some View {
//        FilterButton {
//            withAnimation(.spring()) { onRightAction() }
//        }
//    }
//}
//
////MARK: - 채팅헤더
//struct ChatHeaderView: View {
//    //왼쪽 가운데 오른쪽
//    //타입 , 유저, 액션(왼쪽 오른쪽)
//    var state: HeaderType
//    var user: User
//    var onLeftAction: () -> Void
//    var onRightAction: () -> Void
//
//    var body: some View {
//        HStack(alignment: .center) {
//            switch state {
//            case .chat: // 오른쪽버튼을 눌러 헤더를 확장했을때 나오는 정보가 다름
//                leftSideButton
//                Spacer()
//                centerArea
//                Spacer()
//                rightSideButton
//            case .matchingSuccess: // 오른쪽버튼을 눌러 헤더를 확장했을때 나오는 정보가 다름
//                leftSideButton
//                Spacer()
//                centerArea
//                Spacer()
//                rightSideButton
//            case .homeDetail , .home , .myProfile , .opponentDetail:
//                EmptyView()
//            }
//            leftSideButton
//            Spacer()
//            centerArea
//            Spacer()
//            rightSideButton
//        }
//    }
//
//    private var leftSideButton: some View {
//        Button(action: { onLeftAction() }) {
//            Image(systemName: "chevron.left")
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(.black)
//                .frame(width: 40, height: 40)
//                .background(Color.white.opacity(0.8))
//        }
//    }
//
//    private var centerArea: some View {
//        VStack(alignment: .center) {
//            Image(user.profileImage)
//                .resizable()
//                .scaledToFill()
//                .clipShape(Circle())
//            HStack {
//                Text(user.name)
//                    .font(.meetKey(.title5))
//                if let badgeData = user.badge {
//                    let type = BadgeType1.from(score: badgeData.totalScore)
//                    let circleBadgeName = type.assetName.replacingOccurrences(
//                        of: "Badge",
//                        with: ""
//                    )
//
//                    Image(circleBadgeName)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width: 20, height: 20)
//                }
//            }
//        }
//    }
//
//    private var rightSideButton: some View {
//        Button(action: { onRightAction() }) {
//            Image(systemName: "ellipsis")
//                .rotationEffect(.degrees(90))
//                .font(.system(size: 20, weight: .bold))
//                .foregroundColor(.black)
//                .frame(width: 40, height: 40)
//                .background(Color.white.opacity(0.8))
//                .clipShape(Circle())
//        }
//    }
//}
