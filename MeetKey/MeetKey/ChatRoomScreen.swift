import SwiftUI
import PhotosUI

// Main
struct ChatRoomScreen: View {

    @Binding var chat: ChatItem   // unread 읽음처리 가능

    private let orange = Color("Orange")
    private let pageBg = Color(white: 0.98)

    @Environment(\.dismiss) private var dismiss

    @State private var isMissionExpanded: Bool = true
    @State private var isMissionDone: Bool = false

    @State private var messages: [ChatMessage] = [
        .init(text: "Hi! Is this your first time using\nthe app?", isMe: false, time: "10:33", imageData: nil),
        .init(text: "Hi! Yes, it is. It looks pretty easy\nso far 🙂", isMe: true, time: "10:33", imageData: nil),
        .init(text: "Great! Let me know if you\nneed any help.", isMe: false, time: "10:33", imageData: nil),
        .init(text: "Thanks! I really appreciate it.", isMe: true, time: "10:33", imageData: nil)
    ]

    @State private var inputText: String = ""

    // 사진 첨부 state
    @State private var pickedPhotoItem: PhotosPickerItem? = nil
    @State private var pickedImageData: Data? = nil

    var body: some View {
        ZStack {
            pageBg.ignoresSafeArea()

            VStack(spacing: 0) {

                SimpleHeader(
                    profileImageName: "Jane",
                    badgeImageName: "gold",
                    title: chat.name,
                    onTapBack: { dismiss() }
                )

                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {

                            if isMissionExpanded {
                                MissionExpandedCard(
                                    orange: orange,
                                    isDone: isMissionDone,
                                    keyImageName: "meetkey_profile",
                                    onToggleExpand: {
                                        withAnimation(.easeInOut(duration: 0.18)) {
                                            isMissionExpanded = false
                                        }
                                    },
                                    onTapDone: { isMissionDone.toggle() }
                                )
                                .padding(.top, 10)
                            } else {
                                MissionCollapsedBar(
                                    orange: orange,
                                    keyImageName: "meetkey_profile",
                                    onToggleExpand: {
                                        withAnimation(.easeInOut(duration: 0.18)) {
                                            isMissionExpanded = true
                                        }
                                    }
                                )
                                .padding(.top, 10)
                            }

                            VStack(spacing: 18) {
                                ForEach(messages) { msg in
                                    ChatMessageRow(message: msg, orange: orange)
                                        .id(msg.id)
                                }
                            }

                            Spacer(minLength: 110)
                        }
                        .padding(.horizontal, 18)
                        .padding(.bottom, 6)
                    }
                    .onChange(of: messages.count) { _ in
                        guard let last = messages.last else { return }
                        withAnimation(.easeOut(duration: 0.2)) {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                ChatFooter(
                    orange: orange,
                    inputText: $inputText,
                    pickedPhotoItem: $pickedPhotoItem,
                    pickedImageData: $pickedImageData,
                    onSend: sendMessage
                )
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            // 뒤로가기 해서 리스트로 돌아오면 읽음처리
            if chat.unread > 0 { chat.unread = 0 }
        }
        .onChange(of: pickedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run {
                        pickedImageData = data
                    }
                }
            }
        }
    }

    private func sendMessage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)

        // 텍스트도 없고 사진도 없으면 전송 X
        if trimmed.isEmpty && pickedImageData == nil { return }

        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        messages.append(
            .init(
                text: trimmed.isEmpty ? nil : trimmed,
                isMe: true,
                time: formatter.string(from: Date()),
                imageData: pickedImageData
            )
        )

        // 전송 후 초기화
        inputText = ""
        pickedPhotoItem = nil
        pickedImageData = nil
    }
}

// Model
struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String?
    let isMe: Bool
    let time: String
    let imageData: Data?
}

// Header
struct SimpleHeader: View {

    let profileImageName: String
    let badgeImageName: String
    let title: String
    let onTapBack: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color(red: 0.93, green: 0.93, blue: 0.93).opacity(0.85)
                .overlay(
                    Color(red: 0.93, green: 0.93, blue: 0.93)
                        .opacity(0.85)
                        .blur(radius: 17.5)
                        .clipShape(BottomRoundedShape(radius: 24))
                )
                .clipShape(BottomRoundedShape(radius: 24))
                .shadow(color: .black.opacity(0.03), radius: 10, x: 0, y: 6)
                .ignoresSafeArea(edges: .top)

            HStack(alignment: .center, spacing: 0) {

                Button(action: onTapBack) {
                    CircleIcon(bg: Color(white: 0.86), systemIcon: "arrow.left")
                }
                .buttonStyle(.plain)

                Spacer()

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

                Spacer()

                CircleIcon(bg: Color(white: 0.86), systemIcon: "phone.fill")
            }
            .padding(.horizontal, 20)
        }
        .frame(height: 120)
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

// 아래 두 모서리만 둥글게
struct BottomRoundedShape: Shape {
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(radius, min(rect.width, rect.height) / 2)

        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - r))
        path.addArc(center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
                    radius: r,
                    startAngle: .degrees(0),
                    endAngle: .degrees(90),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + r, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
                    radius: r,
                    startAngle: .degrees(90),
                    endAngle: .degrees(180),
                    clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

// Mission (원본 그대로)
struct MissionExpandedCard: View {
    let orange: Color
    let isDone: Bool
    let keyImageName: String
    let onToggleExpand: () -> Void
    let onTapDone: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {

            VStack(alignment: .leading, spacing: 10) {

                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(red: 1.0, green: 0.90, blue: 0.74))
                            .frame(width: 44, height: 44)

                        Image(keyImageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("오늘의 미션")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)

                        HStack(spacing: 8) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(orange)

                            Text("2시간 남음")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(orange)
                        }
                    }

                    Spacer()
                }

                Text("서로 자신의 나라의 음식을 공유하세요.")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(white: 0.52))
                    .padding(.leading, 56)
                    .fixedSize(horizontal: false, vertical: true)

                Button(action: onTapDone) {
                    Text("미션 완료")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(isDone ? Color(white: 0.75) : orange))
                }
                .padding(.leading, 56)
                .padding(.top, 2)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 1, green: 0.99, blue: 0.91), location: 0.00),
                        .init(color: Color(red: 1, green: 0.97, blue: 0.93), location: 1.00),
                    ],
                    startPoint: UnitPoint(x: -0.1, y: -0.37),
                    endPoint: UnitPoint(x: 1.14, y: 1.28)
                )
            )
            .cornerRadius(14)
            .shadow(color: .black.opacity(0.10), radius: 2.5, x: 0, y: 1)

            Button(action: onToggleExpand) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(white: 0.55))
                    .padding(18)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 6)
            .padding(.top, 6)
        }
    }
}

struct MissionCollapsedBar: View {
    let orange: Color
    let keyImageName: String
    let onToggleExpand: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: Color(red: 1, green: 0.99, blue: 0.91), location: 0.00),
                            .init(color: Color(red: 1, green: 0.97, blue: 0.93), location: 1.00),
                        ],
                        startPoint: UnitPoint(x: -0.1, y: -0.37),
                        endPoint: UnitPoint(x: 1.14, y: 1.28)
                    )
                )
                .shadow(color: .black.opacity(0.10), radius: 2.5, x: 0, y: 1)

            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 1.0, green: 0.90, blue: 0.74))
                        .frame(width: 40, height: 40)

                    Image(keyImageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 26, height: 26)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("오늘의 미션")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)

                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(orange)

                        Text("2시간 남음")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(orange)
                    }
                }

                Spacer()

                Button(action: onToggleExpand) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(white: 0.55))
                        .padding(10)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 78)
    }
}

// Messages
struct ChatMessageRow: View {
    let message: ChatMessage
    let orange: Color

    var body: some View {
        HStack {
            if message.isMe { Spacer(minLength: 56) }
            ChatBubble(message: message, orange: orange)
            if !message.isMe { Spacer(minLength: 56) }
        }
    }
}

struct ChatBubble: View {

    let message: ChatMessage
    let orange: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            // 이미지가 있으면 먼저 보여줌
            if let data = message.imageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 260, height: 180)
                    .clipped()
                    .cornerRadius(14)
            }

            // 텍스트가 있으면 보여줌
            if let text = message.text, !text.isEmpty {
                Text(text)
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(message.isMe ? .white : Color(white: 0.12))
                    .multilineTextAlignment(.leading)
            }

            Text(message.time)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(message.isMe ? Color.white.opacity(0.65) : Color(white: 0.70))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(message.isMe ? orange : .white)
                .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
        .frame(maxWidth: 290, alignment: message.isMe ? .trailing : .leading)
    }
}

// Footer
struct ChatFooter: View {

    let orange: Color
    @Binding var inputText: String

    // 사진 첨부 바인딩
    @Binding var pickedPhotoItem: PhotosPickerItem?
    @Binding var pickedImageData: Data?

    let onSend: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.container, edges: .bottom)

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    Circle()
                        .fill(orange)
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        )

                    Text("대화 주제 추천 받기  5/5")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(orange)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 5)
                        .overlay(Capsule().stroke(orange, lineWidth: 1))

                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.top, 10)

                HStack(spacing: 14) {

                    ZStack {
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color(white: 0.92))
                            .frame(height: 64)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 5)

                        HStack(spacing: 12) {

                            // 플러스 버튼 = 사진 선택
                            PhotosPicker(selection: $pickedPhotoItem, matching: .images) {
                                Circle()
                                    .fill(Color(white: 0.88))
                                    .frame(width: 46, height: 46)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(Color(white: 0.45))
                                    )
                            }
                            .buttonStyle(.plain)
                            .padding(.leading, 10)

                            // 사진 선택되면 작은 썸네일 표시 + X로 제거
                            if let data = pickedImageData, let uiImage = UIImage(data: data) {
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 44, height: 44)
                                        .clipped()
                                        .cornerRadius(10)

                                    Button {
                                        pickedPhotoItem = nil
                                        pickedImageData = nil
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundColor(.white)
                                            .shadow(radius: 2)
                                    }
                                    .buttonStyle(.plain)
                                    .offset(x: 6, y: -6)
                                }
                            }

                            TextField("Type a message", text: $inputText)
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(Color(white: 0.18))
                                .submitLabel(.send)
                                .onSubmit(onSend)

                            Spacer()
                        }
                    }

                    Button(action: onSend) {
                        Circle()
                            .fill(orange)
                            .frame(width: 64, height: 64)
                            .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 5)
                            .overlay(
                                Image(systemName: "mic.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 18)

                Spacer(minLength: 2)
            }
        }
        .frame(height: 118)
        .overlay(
            Rectangle()
                .fill(Color.black.opacity(0.05))
                .frame(height: 1),
            alignment: .top
        )
    }
}

#Preview {
    // 프리뷰에서 Binding 만들기 위한 임시 State
    struct Wrapper: View {
        @State var sampleChat = ChatItem(
            id: UUID(),
            name: "Jane Smith",
            preview: "Ciao! Let me know when you ar...",
            time: "3h",
            unread: 12,
            badge: "gold"
        )

        var body: some View {
            NavigationStack {
                ChatRoomScreen(chat: $sampleChat)
            }
        }
    }

    return Wrapper()
}

