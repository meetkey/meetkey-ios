import SwiftUI
import AVFoundation

struct RecordingCard: View {

    enum Phase {
        case ready       // 1) 녹음 시작 전
        case recording   // 2) 녹음 중
        case done        // 3) 녹음 완료
    }

    // MARK: - State
    @State private var phase: Phase = .ready
    @State private var elapsedSeconds: Int = 0
    @State private var timer: Timer? = nil

    // ✅ 실제 녹음기
    @State private var recorder: AVAudioRecorder? = nil
    @State private var recordedURL: URL? = nil

    // MARK: - Callbacks
    var onClose: (() -> Void)? = nil
    /// ✅ (파일URL, 길이초) 보내기
    var onSend: ((URL, Int) -> Void)? = nil

    // MARK: - Design
    private let orange = Color("Orange01")

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)

            VStack(spacing: 18) {

                // top bar (X)
                HStack {
                    Spacer()
                    Button {
                        resetToReady()
                        onClose?()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.gray.opacity(0.7))
                            .padding(8)
                    }
                }
                .padding(.top, 6)
                .padding(.horizontal, 10)

                // icon circle
                ZStack {
                    Circle()
                        .stroke(orange, lineWidth: 2)
                        .frame(width: 78, height: 78)

                    Circle()
                        .fill(orange)
                        .frame(width: 30, height: 30)

                    centerIcon
                }
                .padding(.top, 4)

                // title + time
                VStack(spacing: 8) {
                    Text(titleText)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color.gray.opacity(0.75))

                    Text(timeText)
                        .font(.system(size: phase == .done ? 26 : 30, weight: .bold))
                        .foregroundColor(.black)
                        .monospacedDigit()
                }

                // buttons
                HStack(spacing: 14) {

                    // ✅ Cancel: 언제 눌러도 ready로 초기화
                    Button {
                        resetToReady()
                    } label: {
                        Text("취소")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color.gray.opacity(0.7))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(Color.gray.opacity(0.12))
                            )
                    }

                    // right
                    Button {
                        handleRightButton()
                    } label: {
                        Text(rightButtonTitle)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(rightButtonIsPrimary ? .white : Color.gray.opacity(0.65))
                            .frame(maxWidth: .infinity)
                            .frame(height: 46)
                            .background(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(rightButtonBackground)
                            )
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
        .frame(width: 320, height: 330)
        .onDisappear {
            stopTimer()
        }
    }

    // MARK: - Center Icon
    @ViewBuilder
    private var centerIcon: some View {
        switch phase {
        case .ready:
            Image(systemName: "play.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

        case .recording:
            Image(systemName: "pause.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)

        case .done:
            Image(systemName: "mic.fill")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
        }
    }

    // MARK: - Texts
    private var titleText: String {
        switch phase {
        case .ready: return "녹음 시작"
        case .recording: return "녹음 중"
        case .done: return "녹음 완료"
        }
    }

    private var timeText: String {
        switch phase {
        case .ready:
            return "00:00"
        case .recording:
            return formatMMSS(elapsedSeconds)
        case .done:
            return formatHHMMSS(elapsedSeconds)
        }
    }

    // MARK: - Right Button UI
    private var rightButtonTitle: String {
        switch phase {
        case .ready: return "녹음 시작"
        case .recording: return "녹음 종료"
        case .done: return "보내기"
        }
    }

    private var rightButtonIsPrimary: Bool {
        phase == .ready || phase == .done
    }

    private var rightButtonBackground: Color {
        switch phase {
        case .ready, .done:
            return orange
        case .recording:
            return Color.gray.opacity(0.15) // 비활성 느낌
        }
    }

    // MARK: - Actions
    private func handleRightButton() {
        switch phase {
        case .ready:
            elapsedSeconds = 0
            recordedURL = nil
            startRecording()
            phase = .recording
            startTimer()

        case .recording:
            stopTimer()
            stopRecording()
            phase = .done

        case .done:
            guard let url = recordedURL else { return }
            onSend?(url, elapsedSeconds)
        }
    }

    // ✅ 취소 누르면 여기로: 항상 초기화
    private func resetToReady() {
        stopTimer()
        stopRecording(deleteFile: true)
        elapsedSeconds = 0
        recordedURL = nil
        phase = .ready
    }

    // MARK: - Timer
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedSeconds += 1
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Recording (AVAudioRecorder)
    private func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)

            let url = makeNewRecordingURL()
            recordedURL = url

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]

            let r = try AVAudioRecorder(url: url, settings: settings)
            r.isMeteringEnabled = false
            r.prepareToRecord()
            r.record()

            recorder = r
        } catch {
            // 녹음 시작 실패하면 ready로 복귀
            resetToReady()
        }
    }

    private func stopRecording(deleteFile: Bool = false) {
        recorder?.stop()
        recorder = nil

        if deleteFile, let url = recordedURL {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private func makeNewRecordingURL() -> URL {
        let dir = FileManager.default.temporaryDirectory
        let name = "meetkey_record_\(UUID().uuidString).m4a"
        return dir.appendingPathComponent(name)
    }

    // MARK: - Formatting
    private func formatMMSS(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    private func formatHHMMSS(_ seconds: Int) -> String {
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}

#Preview {
    RecordingCard(
        onClose: { print("close") },
        onSend: { url, secs in print("send \(secs), \(url)") }
    )
    .padding()
    .background(Color.black.opacity(0.05))
}
