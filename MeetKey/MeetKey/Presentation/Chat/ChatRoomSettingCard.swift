import SwiftUI

struct ChatRoomSettingCard: View {
    
    // MARK: - Inputs
    let profileImageName: String
    let badgeImageName: String
    let title: String
    let onTapBack: () -> Void
    let onTapCall: () -> Void
    let onTapProfile: () -> Void
    @Binding var isExpanded: Bool
    
    // MARK: - States
    @State private var isAlarmOn: Bool = true
    
    // MARK: - Design
    private let bg = Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.85)
    
    var body: some View {
        ZStack(alignment: .top) {
            
            bg
                .overlay(
                    bg
                        .blur(radius: 17.5)
                        .clipShape(BottomRoundedShape(radius: 24))
                )
                .clipShape(BottomRoundedShape(radius: 24))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 6)
                .ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                topRow
                
                if isExpanded {
                    Divider()
                        .opacity(0.25)
                        .padding(.top, 14)
                    
                    menuList
                        .padding(.top, 6)
                        .padding(.bottom, 14)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
        // ✅ 같은 카드가 아래로 "연장"되는 느낌
        .frame(height: isExpanded ? 360 : 120)
        .animation(.easeInOut(duration: 0.18), value: isExpanded)
    }

    // MARK: - Top Row
    private var topRow: some View {
        HStack(alignment: .center, spacing: 0) {

            Button(action: onTapBack) {
                CircleIcon(bg: Color(white: 0.86), systemIcon: "arrow.left")
            }
            .buttonStyle(.plain)

            Spacer()

            // ✅ 이름/뱃지 영역 누르면 펼침/접힘
            Button {
                withAnimation(.easeInOut(duration: 0.18)) {
                    isExpanded.toggle()
                }
            } label: {
                VStack(spacing: 10) {
                    Image(profileImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(Circle())
                    
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(Color(white: 0.12))
                        
                        Image(badgeImageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onTapCall) {
                CircleIcon(bg: Color(white: 0.86), systemIcon: "phone.fill")
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Menu List
    private var menuList: some View {
        VStack(spacing: 0) {
            SettingRow(icon: "person", title: "프로필 보기", tint: Color(white: 0.35)) {
                // TODO
            }

            Divider().opacity(0.15)

            HStack(spacing: 12) {
                SettingIcon(systemName: "bell", tint: Color(white: 0.35))
                Text("알림")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(white: 0.20))
                Spacer()
                Toggle("", isOn: $isAlarmOn)
                    .labelsHidden()
                    .tint(Color("Orange01"))
            }
            .padding(.vertical, 14)
            
            Divider().opacity(0.15)
            
            SettingRow(icon: "rectangle.portrait.and.arrow.right", title: "채팅방 나가기", tint: Color(white: 0.35)) {
                // TODO
            }
            
            Divider().opacity(0.15)
            
            SettingRow(icon: "xmark", title: "차단하기", tint: Color(white: 0.35)) {
                // TODO
            }
            
            Divider().opacity(0.15)
            
            SettingRow(icon: "exclamationmark.triangle", title: "신고하기", tint: Color("Orange01")) {
                // TODO
            }
        }
    }
}

// MARK: - Small Components
private struct SettingRow: View {
    let icon: String
    let title: String
    let tint: Color
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                SettingIcon(systemName: icon, tint: tint)
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tint == Color("Orange01") ? tint : Color(white: 0.20))
                Spacer()
            }
            .padding(.vertical, 14)
        }
        .buttonStyle(.plain)
    }
}

private struct SettingIcon: View {
    let systemName: String
    let tint: Color
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(tint)
            .frame(width: 22, height: 22, alignment: .center)
    }
}

struct CircleIcon: View {
    let bg: Color
    let systemIcon: String
    
    var body: some View {
        Circle()
            .fill(bg)
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: systemIcon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(white: 0.18))
            )
    }
}

// ✅ 아래 두 모서리만 둥글게
struct BottomRoundedShape: Shape {
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(radius, min(rect.width, rect.height) / 2)
        
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        
        path.addArc(
            center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(0),
            endAngle: .degrees(90),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        
        path.addArc(
            center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
            radius: r,
            startAngle: .degrees(90),
            endAngle: .degrees(180),
            clockwise: false
        )
        
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    struct Wrapper: View {
        @State var expanded = true
        var body: some View {
            ChatRoomSettingCard(
                profileImageName: "Jane",
                badgeImageName: "gold",
                title: "Jane Smith",
                onTapBack: { },
                onTapCall: { },
                onTapProfile: { },
                isExpanded: $expanded
            )
        }
    }
    return Wrapper()
}
