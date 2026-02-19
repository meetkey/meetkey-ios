import Combine
import CoreLocation
import Foundation
import SwiftUI

enum HomeStatus {
    case loading
    case idle
    case matching
    case finished
}

@MainActor
class HomeViewModel: ObservableObject {

    @Published var status: HomeStatus = .loading
    @Published var filter = FilterModel()

    @Published var me = User.me
    @Published var allUsers: [User] = []
    @Published var currentUser: User?
    @Published private(set) var currentIndex: Int = 0

    @Published var isDetailViewPresented: Bool = false
    @Published var isFilterViewPresented: Bool = false
    @Published var isMatchViewPresented: Bool = false
    @Published var hasReachedLimit: Bool = false

    @Published var remainingCount: Int = 0
    @Published var totalCount: Int = 0

    @Published var currentFilter = RecommendationRequest()
    @Published var reportVM = ReportViewModel()

    @Published var matchMessageText: String = ""
    @Published var matchedRoomId: Int? = nil
    @Published var isChattingStarted: Bool = false
    @Published var matchChatMessages: [ChatMessageDTO] = []

    private let locationManager = LocationManager.shared
    private let locationService = LocationService.shared
    private let recommendationService = RecommendationService.shared
    private var cancellables = Set<AnyCancellable>()

    let users: [User] = User.mockData

    // MARK: - Initialization
    init() {
        setupReportViewModel()
        setupLocationManager()
    }

    // MARK: - Setup Methods
    private func setupReportViewModel() {
        reportVM.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        reportVM.onFinalize = { [weak self] in
            print("📍 [HomeVM] Report/Block Finalize Signal Received")
            self?.finalizeReportProcess()
        }
    }

    private func setupLocationManager() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                print("📍 [HomeVM] Initial Location Received")

                Task {
                    await self?.sendLocationToServer(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )

                    await self?.fetchRecommendations(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )
                }
            }
            .store(in: &cancellables)

        print("📍 [HomeVM] Requesting Location...")
        locationManager.requestLocation()
    }

    // MARK: - API Requests
    private func sendLocationToServer(latitude: Double, longitude: Double) async
    {
        print("📍 [HomeVM] Sending Location to Server...")
        do {
            try await locationService.updateMyLocation(
                latitude: latitude,
                longitude: longitude
            )
            print("✅ [HomeVM] Location Update Success")
        } catch {
            print("❌ [HomeVM] Location Update Failed: \(error)")
        }
    }

    func fetchUserAsync(isRetry: Bool = false) async {
        print("📍 [HomeVM] Fetching Users...")
        status = .loading

        do {
            let response = try await recommendationService.getRecommendation(
                filter: currentFilter
            )

            let swipeInfo = response.data.swipeInfo
            self.remainingCount = swipeInfo.remainingCount
            self.totalCount = swipeInfo.totalCount
            self.hasReachedLimit = (self.remainingCount == 0)

            print("📊 [Swipe] \(remainingCount)/\(totalCount)")

            let recommendations = response.data.recommendations
            print("✅ [HomeVM] Fetched User Count: \(recommendations.count)")

            if recommendations.isEmpty {
                self.allUsers = []
                self.currentUser = nil
                status = .finished
            } else {
                self.allUsers = recommendations.map { User(from: $0) }
                self.currentIndex = 0
                self.currentUser = self.allUsers.first
                status = .idle
            }
        } catch {
            print("❌ [HomeVM] Data Fetch Failed: \(error)")

            if let netError = error as? NetworkError,
               case .serverError(let code, _) = netError,
               code == "COMMON500",
               !isRetry {
                
                print("🔄 [HomeVM] 서버 잠깨우는 중... 0.5초 후 재시도합니다.")
                
                try? await Task.sleep(nanoseconds: 500_000_000)
                
                await fetchUserAsync(isRetry: true)
                return
            }

            status = .finished
        }
    }

    func fetchRecommendations(latitude: Double, longitude: Double) async {
        let interestsRaw = filter.interests?.compactMap { korName in
            InterestType.allCases.first(where: { $0.displayName == korName })?
                .rawValue
        }

        let personalityRaw: [String] = filter.combinedPersonalities ?? []
        let hometownRaw = NationalityType.allCases.first(where: {
            $0.displayName == filter.hometown
        })?.rawValue
        let nativeLangRaw = LanguageType.allCases.first(where: {
            $0.displayName == filter.nativeLanguage
        })?.rawValue
        let targetLangRaw = LanguageType.allCases.first(where: {
            $0.displayName == filter.targetLanguage
        })?.rawValue
        let targetLangLevelRaw = LanguageLevelType.allCases.first(where: {
            $0.displayName == filter.targetLanguageLevel
        })?.rawValue

        let request = RecommendationRequest(
            maxDistance: filter.maxDistance,
            minAge: filter.minAge,
            maxAge: filter.maxAge,
            interests: interestsRaw,
            hometown: hometownRaw,
            nativeLanguage: nativeLangRaw,
            targetLanguage: targetLangRaw,
            targetLanguageLevel: targetLangLevelRaw,
            personality: personalityRaw,
            latitude: latitude,
            longitude: longitude
        )

        currentFilter = request
        print("📮 [HomeVM] Filter Applied: \(request.toDictionary())")

        await fetchUserAsync()
    }

    // MARK: - Filter Actions
    func applyFilter(_ newFilter: FilterModel) {
        print("📍 [HomeVM] Apply New Filter")
        filter = newFilter

        if let location = LocationManager.shared.currentLocation {
            Task {
                await fetchRecommendations(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
        } else {
            print("⚠️ [HomeVM] No Current Location Data")
        }
    }

    var groupedInterests: [InterestGroup] {
        let all = InterestType.allCases
        return [
            InterestGroup(category: "일상 · 라이프스타일", items: Array(all[0...9])),
            InterestGroup(category: "문화 · 콘텐츠", items: Array(all[10...20])),
            InterestGroup(category: "지식 · 시사", items: Array(all[21...31])),
        ]
    }

    // MARK: - User Actions
    func handleLikeAction() {
        guard let targetUser = currentUser else { return }
        print("📍 [HomeVM] Like Action (Target ID: \(targetUser.id))")

        Task {
            do {
                try await RecommendationService.shared.sendUserAction(
                    targetId: targetUser.id,
                    action: .like
                )
            } catch {
                print("❌ [HomeVM] Like API Error: \(error)")
            }
        }
        presentMatchView()
    }

    func handleSkipAction() {
        guard let targetUser = currentUser else { return }
        print("📍 [HomeVM] Skip Action (Target ID: \(targetUser.id))")

        Task {
            do {
                try await RecommendationService.shared.sendUserAction(
                    targetId: targetUser.id,
                    action: .skip
                )
            } catch {
                print("❌ [HomeVM] Skip API Error: \(error)")
            }
        }
        moveToNextUser()
    }

    private func moveToNextUser() {
        withAnimation {
            if currentIndex < allUsers.count - 1 {
                currentIndex += 1
                currentUser = allUsers[currentIndex]
                print("📍 [HomeVM] Move to Next User: \(currentIndex)")
            } else {
                status = .finished
                print("📍 [HomeVM] Reached Final User")
            }
        }
    }

    func resetDiscovery() {
        print("📍 [HomeVM] Reset Discovery")
        currentIndex = 0
        currentUser = allUsers.first
        status = allUsers.isEmpty ? .finished : .idle
    }

    // MARK: - Report & Block Process
    func finalizeReportProcess() {
        withAnimation(.easeInOut) {
            reportVM.closeReportMenu()
            self.moveToNextUser()
            self.dismissMatchView()
        }
    }

    // MARK: - View Presentation
    func presentDetailView() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isDetailViewPresented = true
        }
    }
    func dismissDetailView() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isDetailViewPresented = false
        }
    }
    func presentMatchView() { isMatchViewPresented = true }
    func dismissMatchView() {
        isMatchViewPresented = false
        reportVM.closeReportMenu()
    }
    func presentFilterView() { isFilterViewPresented = true }
    func dismissFilterView() { isFilterViewPresented = false }
}

// MARK: - Helper Struct
extension HomeViewModel {
    struct InterestGroup: Identifiable {
        let id = UUID()
        let category: String
        let items: [InterestType]
    }
}
//MARK: - 채팅

extension HomeViewModel {
    func sendInitialMatchMessage() async {
        // 1. 입력값 유효성 검사 및 전송할 텍스트 보관
        let content = matchMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return }
        
        do {
            // 2. 채팅방 생성 로직 (방이 없는 경우에만 생성)
            if matchedRoomId == nil {
                guard let targetUserId = currentUser?.id else {
                    print("❌ 오류: 대상 사용자 ID를 찾을 수 없습니다.")
                    return
                }
                let response = try await ChatService.shared.createChatRoom(targetUserId: targetUserId)
                self.matchedRoomId = response.createdChatRoomId
            }
            
            // 3. 방 ID 옵셔널 바인딩 (DTO 생성을 위해 필수)
            guard let roomId = matchedRoomId else {
                print("❌ 오류: 생성된 방 ID가 없습니다.")
                return
            }
            
            // 4. ChatMessageDTO 규격에 맞게 메시지 객체 생성
            let newMessage = ChatMessageDTO(
                messageId: Int.random(in: 1...1_000_000),
                chatRoomId: roomId,
                senderId: me.id,
                messageType: .text,
                content: content,
                duration: nil,
                createdAt: DateFormatter.iso8601Full.string(from: Date()),
                mine: true
            )
            
            // 5. 메인 스레드에서 UI 업데이트 및 상태 변경
            await MainActor.run {
                withAnimation(.easeInOut) {
                    self.matchChatMessages.append(newMessage)
                    self.isChattingStarted = true 
                    self.matchMessageText = ""
                }
            }
            
            // 6. (옵션) 서버로 실제 메시지 전송 시도 (STOMP 브릿지)
            ChatService.shared.sendMatchMessage(roomId: roomId, content: content)
            
        } catch {
            print("❌ 매칭 채팅 처리 실패: \(error.localizedDescription)")
        }
    }
}
extension User {
    static let mockData: [User] = [
        User(
            id: 101,
            name: "전효빈",
            profileImage: "profileImageSample1",
            age: 27,
            gender: "MALE",
            homeTown: "KOREA",
            location: "SEOUL",
            distance: "1.2km",
            bio: "iOS 개발자가 되고 싶은 사람입니다. SwiftUI 최고!",
            first: "KOREAN",
            target: "ENGLISH",
            level: "INTERMEDIATE",
            recommendCount: 100,
            notRecommendCount: 0,
            interests: ["SwiftUI", "Xcode", "Git"],
            personalities: Personalities(
                socialType: "EXTROVERT",
                meetingType: "ONE_ON_ONE",
                chatType: "INITIATOR",
                friendType: "ANYONE",
                relationType: "CASUAL"
            ),
            badge: BadgeInfo(
                badgeName: "골드 뱃지",
                totalScore: 95,
                histories: nil
            ),
            birthDate: nil  // 필요시 추가
        ),
        User(
            id: 102,
            name: "김민준",
            profileImage: "profileImageSample2",
            age: 24,
            gender: "MALE",
            homeTown: "KOREA",
            location: "GYEONGGI",
            distance: "3.5km",
            bio: "주말마다 한강에서 러닝하는 거 좋아해요. 같이 뛰실 분?",
            first: "KOREAN",
            target: "JAPANESE",
            level: "NOVICE",
            recommendCount: 50,
            notRecommendCount: 2,
            interests: ["Running", "Coffee"],
            personalities: nil,
            badge: BadgeInfo(
                badgeName: "실버 뱃지",
                totalScore: 82,
                histories: nil
            ),
            birthDate: nil
        ),
        User(
            id: 103,
            name: "이서연",
            profileImage: "profileImageSample1",
            age: 29,
            gender: "FEMALE",
            homeTown: "KOREA",
            location: "SEOUL",
            distance: "0.8km",
            bio: "카페 투어와 사진 촬영이 취미입니다. 기록하는 걸 좋아해요.",
            first: "KOREAN",
            target: "FRENCH",
            level: "ADVANCED",
            interests: ["Photography", "Cafe"],
            personalities: nil,
            badge: BadgeInfo(
                badgeName: "브론즈 뱃지",
                totalScore: 75,
                histories: nil
            ),
            birthDate: nil
        ),
        User(
            id: 104,
            name: "박지성",
            profileImage: "profileImageSample2",
            age: 31,
            gender: "MALE",
            homeTown: "KOREA",
            location: "INCHEON",
            distance: "12km",
            bio: "개발자입니다. 커피 한 잔 하면서 기술 얘기 나누고 싶어요.",
            first: "KOREAN",
            target: "ENGLISH",
            level: "NOVICE",
            interests: ["Java", "Spring"],
            personalities: nil,
            badge: BadgeInfo(
                badgeName: "노멀 뱃지",
                totalScore: 30,
                histories: nil
            ),
            birthDate: nil
        ),
        User(
            id: 105,
            name: "최유진",
            profileImage: "profileImageSample1",
            age: 24,
            gender: "FEMALE",
            homeTown: "KOREA",
            location: "SEOUL",
            distance: "2.1km",
            bio: "이제 막 대학교 졸업했어요! 새로운 사람들을 만나는 건 늘 설레네요.",
            first: "KOREAN",
            target: "SPANISH",
            level: "NOVICE",
            interests: ["Travel", "Movie"],
            personalities: nil,
            badge: BadgeInfo(
                badgeName: "골드 뱃지",
                totalScore: 92,
                histories: nil
            ),
            birthDate: nil
        ),
    ]

    // 로그인 유저 목데이터
    static let me = User(
        id: 1,
        name: "김밋키",
        profileImage: "profileImageSample1",
        age: 24,
        gender: "FEMALE",
        homeTown: "KOREA",
        location: "SEOUL",
        distance: "0km",
        bio: "안녕하세요, 언어 교환 친구를 사귀고 싶어요",
        first: "KOREAN",
        target: "ENGLISH",
        level: "NOVICE",
        recommendCount: 10,
        notRecommendCount: 0,
        interests: ["Language Exchange", "swimming"],
        personalities: nil,
        badge: BadgeInfo(badgeName: "골드 뱃지", totalScore: 99, histories: nil),
        birthDate: DateFormatter.yyyyMMdd.date(from: "2001-01-01")
    )
}
