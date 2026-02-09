import SwiftUI
import PhotosUI
import AVFoundation

// MARK: - Main
struct ChatRoomScreen: View {

    @Binding var chat: ChatItem

    private let orange = Color("Orange01")
    private let pageBg = Color(white: 0.98)

    @Environment(\.dismiss) private var dismiss

    // ✅ 헤더 펼침 상태
    @State private var isSettingExpanded: Bool = false

    // ✅ 대화주제 카드 오픈 상태
    @State private var isTopicCardOpen: Bool = false

    @State private var isMissionExpanded: Bool = true
    @State private var isMissionDone: Bool = false

    @State private var messages: [ChatMessage] = [
        .init(kind: .text("Hi! Is this your first time using\nthe app?"), isMe: false, time: "10:33"),
        .init(kind: .text("Hi! Yes, it is. It looks pretty easy\nso far 🙂"), isMe: true, time: "10:33"),
        .init(kind: .text("Great! Let me know if you\nneed any help."), isMe: false, time: "10:33"),
        .init(kind: .text("Thanks! I really appreciate it."), isMe: true, time: "10:33")
    ]

    @State private var inputText: String = ""

    // 사진 첨부
    @State private var pickedPhotoItem: PhotosPickerItem? = nil
    @State private var pickedImageData: Data? = nil

    // 녹음 카드
    @State private var isShowingRecordingCard: Bool = false

    // 오디오 재생
    @State private var audioPlayer: AVAudioPlayer? = nil
    @State private var playingMessageID: UUID? = nil

    var body: some View {
        ZStack(alignment: .top) {
            pageBg.ignoresSafeArea()

            // ✅ "헤더 아래 전체 화면" 영역 (헤더 펼침/주제카드 오픈 시 blur + 터치막기)
            VStack(spacing: 0) {

                // 헤더 자리(항상 120만 차지)
                headerSlot
                    .zIndex(20)

                // 나머지 콘텐츠
                contentArea
            }
            .zIndex(1)

            // ✅ 헤더 펼쳤을 때 딤 (헤더 아래 / 콘텐츠 위)
            if isSettingExpanded {
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(10)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isSettingExpanded = false
                        }
                    }
            }

            // ✅ 헤더는 딤보다 위에
            headerOverlay
                .zIndex(30)

            // =========================
            // ✅ 대화 주제 추천 카드 오버레이
            // =========================
            if isTopicCardOpen {

                // 뒤 살짝 딤 (회색 배경 X, 그냥 투명 딤)
                Color.black.opacity(0.18)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .zIndex(40)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.18)) {
                            isTopicCardOpen = false
                        }
                    }

                // 카드 자체 (하단 근처에 뜨게)
                VStack {
                    Spacer()

                    TopicSuggestionCard(
                        orange: orange,
                        suggestions: [
                            "How's the weather today?",
                            "How's your day going so far?",
                            "What do you usually do in your free time?",
                            "Do you have any favorite cafes or places around here?",
                            "What kind of music do you like these days?"
                        ],
                        onClose: {
                            withAnimation(.easeInOut(duration: 0.18)) {
                                isTopicCardOpen = false
                            }
                        },
                        onPick: { text in
                            inputText = text
                            withAnimation(.easeInOut(duration: 0.18)) {
                                isTopicCardOpen = false
                            }
                        }
                    )
                    .padding(.horizontal, 18)
                    .padding(.bottom, 200) // 푸터 위로 띄우는 느낌
                }
                .transition(.opacity)
                .zIndex(41)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onDisappear {
            stopAudio()
            if chat.unread > 0 { chat.unread = 0 }
        }
        .onChange(of: pickedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    await MainActor.run { pickedImageData = data }
                }
            }
        }
        .sheet(isPresented: $isShowingRecordingCard) {
            ZStack {
                Color.black.opacity(0.05).ignoresSafeArea()
                RecordingCard(
                    onClose: { isShowingRecordingCard = false },
                    onSend: { url, secs in
                        sendVoice(url: url, durationSec: secs)
                        isShowingRecordingCard = false
                    }
                )
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.hidden)
        }
    }

    // MARK: - Header Slot (자리만 120)
    private var headerSlot: some View {
        Color.clear
            .frame(height: 120)
    }

    // MARK: - Header Overlay (실제 카드: 늘어나며 덮어씀)
    private var headerOverlay: some View {
        ChatRoomSettingCard(
            profileImageName: "Jane",
            badgeImageName: "gold",
            title: chat.name,
            onTapBack: { dismiss() },
            onTapCall: { print("call") },
            isExpanded: $isSettingExpanded
        )
        .frame(maxWidth: .infinity, alignment: .top)
        .allowsHitTesting(true)
    }

    // MARK: - Content
    private var contentArea: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {

                        // ✅ 오늘의 미션 유지
                        if isMissionExpanded {
                            MissionExpandedCard(
                                orange: orange,
                                isDone: isMissionDone,
                                keyImageName: "img_char_meetkey_main",
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
                                keyImageName: "img_char_meetkey_main",
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
                                ChatMessageRow(
                                    message: msg,
                                    orange: orange,
                                    isPlaying: playingMessageID == msg.id,
                                    onTapVoice: { tapped in togglePlay(for: tapped) }
                                )
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
                onSend: sendTextOrImage,
                onTapMic: { isShowingRecordingCard = true },
                onTapTopic: {
                    withAnimation(.easeInOut(duration: 0.18)) {
                        isTopicCardOpen = true
                    }
                }
            )
        }
        // ✅ 헤더 펼침/주제카드 오픈 시 뒤 화면 흐림 + 터치 막기
        .blur(radius: (isSettingExpanded || isTopicCardOpen) ? 2.0 : 0)
        .allowsHitTesting(!(isSettingExpanded || isTopicCardOpen))
        .animation(.easeInOut(duration: 0.18), value: isSettingExpanded)
        .animation(.easeInOut(duration: 0.18), value: isTopicCardOpen)
    }

    // MARK: - Send
    private func sendTextOrImage() {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && pickedImageData == nil { return }

        let time = nowHHMM()

        if let data = pickedImageData {
            messages.append(.init(kind: .image(data), isMe: true, time: time))
        }
        if !trimmed.isEmpty {
            messages.append(.init(kind: .text(trimmed), isMe: true, time: time))
        }

        inputText = ""
        pickedPhotoItem = nil
        pickedImageData = nil
    }

    private func sendVoice(url: URL, durationSec: Int) {
        let time = nowHHMM()
        messages.append(.init(kind: .voice(url: url, durationSec: durationSec), isMe: true, time: time))
    }

    private func nowHHMM() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }

    // MARK: - Audio Play
    private func togglePlay(for msg: ChatMessage) {
        guard case .voice(let url, _) = msg.kind else { return }

        if playingMessageID == msg.id {
            stopAudio()
            return
        }

        stopAudio()

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            audioPlayer = player
            playingMessageID = msg.id
            player.prepareToPlay()
            player.play()

            DispatchQueue.main.asyncAfter(deadline: .now() + player.duration) {
                if playingMessageID == msg.id { stopAudio() }
            }
        } catch {
            stopAudio()
        }
    }

    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        playingMessageID = nil
    }
}

// MARK: - Topic Suggestion Card (컴포넌트)
private struct TopicSuggestionCard: View {

    let orange: Color
    let suggestions: [String]
    let onClose: () -> Void
    let onPick: (String) -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {

            // ✅ 카드 자체: 흰색 (바탕 회색 없음)
            VStack(spacing: 14) {
                Spacer(minLength: 4)

                VStack(spacing: 10) {
                    ForEach(suggestions, id: \.self) { text in
                        Button {
                            onPick(text)
                        } label: {
                            Text(text)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(Color(white: 0.18))
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 60)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(Color.white)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(
                                            Color.black.opacity(0.12),
                                            style: StrokeStyle(lineWidth: 1.2, dash: [4, 4])
                                        )
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 10)
                .padding(.bottom, 18)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 34) // 버튼 공간
            .padding(.horizontal, 14)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.10), radius: 16, x: 0, y: 10)
            )

            // ✅ 주황색 버튼 (닫기)
            Button(action: onClose) {
                Circle()
                    .fill(orange)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: "arrow.down")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 8)
            }
            .buttonStyle(.plain)
            .offset(x: -6, y: -18) // 카드 밖으로 살짝 튀어나오게
        }
    }
}

// MARK: - Model
struct ChatMessage: Identifiable {
    enum Kind {
        case text(String)
        case image(Data)
        case voice(url: URL, durationSec: Int)
    }

    let id = UUID()
    let kind: Kind
    let isMe: Bool
    let time: String
}

// MARK: - Mission
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

// MARK: - Messages UI
struct ChatMessageRow: View {
    let message: ChatMessage
    let orange: Color
    let isPlaying: Bool
    let onTapVoice: (ChatMessage) -> Void

    var body: some View {
        HStack {
            if message.isMe { Spacer(minLength: 56) }
            ChatBubble(message: message, orange: orange, isPlaying: isPlaying, onTapVoice: onTapVoice)
            if !message.isMe { Spacer(minLength: 56) }
        }
    }
}

struct ChatBubble: View {

    let message: ChatMessage
    let orange: Color
    let isPlaying: Bool
    let onTapVoice: (ChatMessage) -> Void

    var body: some View {
        switch message.kind {
        case .text(let text):
            textBubble(text)
        case .image(let data):
            imageBubble(data)
        case .voice(_, let durationSec):
            voiceBubble(durationSec: durationSec)
        }
    }

    private func textBubble(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(text)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(message.isMe ? .white : Color(white: 0.12))
                .multilineTextAlignment(.leading)

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

    private func imageBubble(_ data: Data) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            if let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 260, height: 180)
                    .clipped()
                    .cornerRadius(14)
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

    private func voiceBubble(durationSec: Int) -> some View {
        VStack(alignment: .leading, spacing: 4) {

            Button {
                onTapVoice(message)
            } label: {
                HStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(orange, lineWidth: 2)
                            .frame(width: 30, height: 30)

                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(orange)
                            .offset(x: isPlaying ? 0 : 1)
                    }

                    Text("음성녹음 \(formatMMSS(durationSec))")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(white: 0.12))

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(message.time)
                .font(.system(size: 12, weight: .regular))
                .foregroundColor(Color(white: 0.70))
                .padding(.leading, 14)
                .padding(.top, -2)
        }
        .frame(width: 250, alignment: .leading)
        .padding(.bottom, 6)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(orange, lineWidth: 1.6)
        )
        .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        .frame(maxWidth: 290, alignment: message.isMe ? .trailing : .leading)
    }

    private func formatMMSS(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }
}

// MARK: - Footer
struct ChatFooter: View {

    let orange: Color
    @Binding var inputText: String

    @Binding var pickedPhotoItem: PhotosPickerItem?
    @Binding var pickedImageData: Data?

    let onSend: () -> Void
    let onTapMic: () -> Void

    // ✅ 주제 카드 열기
    let onTapTopic: () -> Void

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea(.container, edges: .bottom)

            VStack(alignment: .leading, spacing: 10) {

                HStack {
                    // ✅ 여기 아이콘을 버튼으로 (클릭하면 카드 열림)
                    Button(action: onTapTopic) {
                        Circle()
                            .fill(orange)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    }
                    .buttonStyle(.plain)

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

                    Button(action: onTapMic) {
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
