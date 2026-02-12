import SwiftUI

enum HeaderType {
    case home
    case homeDetail
    case matchingSuccess
    case chat
//    case myProfile
    case opponentDetail
}

struct HeaderOverlay: View {
    let state: HeaderType
    let user: User
    @ObservedObject var reportVM: ReportViewModel
    
    var onLeftAction: () -> Void = {}
    var onRightAction: () -> Void = {}
    var onDetailAction: () -> Void = {}
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    leftArea
                        .frame(width: 40, height: 40)
                    
                    if state == .home || state == .homeDetail {
                        homeHeaderText
                            .padding(.leading, 8)
                        Spacer()
                    } else {
                        Spacer()
                        centerArea
                        Spacer()
                    }
                    
                    rightArea
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
                .padding(.top, 16)
                
                if reportVM.isReportMenuPresented {
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

extension HeaderOverlay {
    @ViewBuilder
    private var leftArea: some View {
        switch state {
        case .home:
            Button(action: onLeftAction) {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Text(String(user.name.prefix(1)))
                            .foregroundColor(.white)
                    )
            }
        case .chat, .matchingSuccess:
            Button(action: onLeftAction) {
                Image("btn_x_header") // X 아이콘 적용
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        default:
            Button(action: onLeftAction) {
                Image("btn_arrow_header") // 뒤로가기 화살표 적용
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
    }

    @ViewBuilder
    private var centerArea: some View {
        switch state {
        case .home, .homeDetail:
            EmptyView()
            
        case .matchingSuccess, .chat:
            VStack(spacing: 4) {
                AsyncImage(url: URL(string: user.profileImage)) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                    } else {
                        ZStack {
                            Circle().fill(Color.gray.opacity(0.3))
                            Text(String(user.name.prefix(1)))
                                .foregroundColor(.white)
                                .font(.meetKey(.body1))
                        }
                    }
                }
                .frame(width: 44, height: 44)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
                
                HStack(spacing: 4) {
                    Text(user.name)
                        .font(.meetKey(.title5))
                        .foregroundStyle(Color.text1)
                    
                    if let badgeData = user.badge {
                        let type = BadgeType1.from(score: badgeData.totalScore)
                        let circleBadgeName = type.assetName.replacingOccurrences(
                            of: "Badge",
                            with: ""
                        )

                        Image(circleBadgeName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .padding(.top, 8)

        default:
            Text(user.name)
                .font(.meetKey(.title5))
                .foregroundStyle(Color.text1)
        }
    }

    @ViewBuilder
    private var rightArea: some View {
        if state == .home || state == .homeDetail {
            Button(action: {
                withAnimation(.spring()) { onRightAction() }
            }) {
                Image("btn_filter_header") // 필터 아이콘 적용
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        } else {
            Button(action: {
                withAnimation(.spring()) { onRightAction() }
            }) {
                Image("btn_ellipsis_header") // 더보기(점세개) 아이콘 적용
                    .resizable()
                    .frame(width: 40, height: 40)
            }
        }
    }

    private var homeHeaderText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(user.name + "님,")
                .font(.meetKey(.body5))
                .foregroundStyle(Color.text5)
            Text("이런 친구는 어때요?")
                .font(.meetKey(.body1))
                .foregroundStyle(Color.text3)
        }
    }

    private var reportMenuList: some View {
        VStack(spacing: 0) {
            menuItem(title: "프로필 보기", icon: "btn_profile_header") {
                onDetailAction()
            }
            Divider().padding(.horizontal, 10)
            menuItem(title: "차단하기", icon: "btn_block_header") {
                reportVM.currentReportStep = .block
            }
            Divider().padding(.horizontal, 10)
            menuItem(title: "신고하기", icon: "btn_report_header", isDestructive: true) {
                reportVM.currentReportStep = .report
            }
        }
        .padding(.bottom, 10)
    }

    private func menuItem(title: String, icon: String, isDestructive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation {
                reportVM.isReportMenuPresented = false
                action()
            }
        }) {
            HStack(spacing: 15) {
                Image(icon) // 메뉴 아이콘 커스텀 에셋 적용
                    .resizable()
                    .frame(width: 24, height: 24)
                Text(title)
                Spacer()
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(isDestructive ? .red : .black)
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .contentShape(Rectangle())
        }
    }
}
