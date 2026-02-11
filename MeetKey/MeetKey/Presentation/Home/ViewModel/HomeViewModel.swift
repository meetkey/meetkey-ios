//
//  HomeViewModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Combine
import Foundation
import SwiftUI
import CoreLocation

//MARK: - HomeStatus Enum
enum HomeStatus {
    case loading
    case idle
    case matching
    case finished
}

//MARK: - HomeViewModel
@MainActor
class HomeViewModel: ObservableObject {
    
    //MARK: - Properties
    
    // State
    @Published var status: HomeStatus = .loading
    @Published var filter = FilterModel()
    
    // Data
    @Published var me = User.me
    @Published var allUsers: [User] = []
    @Published var currentUser: User?
    @Published private(set) var currentIndex: Int = 0
    
    // View Control
    @Published var isDetailViewPresented: Bool = false
    @Published var isFilterViewPresented: Bool = false
    @Published var isMatchViewPresented: Bool = false
    @Published var hasReachedLimit: Bool = false
    
    // Services
    @Published var currentFilter = RecommendationRequest()
    @Published var reportVM = ReportViewModel()
    
    private let locationManager = LocationManager.shared
    private let recommendationService = RecommendationService.shared
    private var cancellables = Set<AnyCancellable>()
    
    let users: [User] = User.mockData
    
    //MARK: - Initialization
    
    init() {
        setupReportViewModel()
        setupLocationManager()
    }
    
    private func setupReportViewModel() {
        reportVM.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        reportVM.onFinalize = { [weak self] in
            self?.finalizeReportProcess()
        }
    }
    
    private func setupLocationManager() {
        locationManager.$currentLocation
            .compactMap { $0 }
            .first()
            .sink { [weak self] location in
                print("📍 HomeViewModel이 위치 받음")
                self?.fetchRecommendations(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }
            .store(in: &cancellables)
        
        print("📍 위치 요청 시작")
        locationManager.requestLocation()
    }
    
    //MARK: - API Requests
    
    func fetchUserAsync() async {
        print("패치유저")
        status = .loading

        do {
            let fetchedData = try await recommendationService.getRecommendation(
                filter: currentFilter
            )
            print("서버에서 받은 유저수: \(fetchedData.count)")

            if fetchedData.isEmpty {
                status = .finished
            } else {
                self.allUsers = fetchedData
                self.currentIndex = 0
                self.currentUser = fetchedData.first
                status = .idle
            }
        } catch {
            print("데이터 로딩 실패: \(error)")
        }
    }
    
    func fetchRecommendations(latitude: Double, longitude: Double) {
        let interestsRaw = filter.interests?.compactMap { korName in
            InterestType.allCases.first(where: { $0.displayName == korName })?.rawValue
        }
        
        let personalityRaw: [String] = filter.combinedPersonalities ?? []
        
        let hometownRaw = NationalityType.allCases.first(where: { $0.displayName == filter.hometown })?.rawValue
        let nativeLangRaw = LanguageType.allCases.first(where: { $0.displayName == filter.nativeLanguage })?.rawValue
        let targetLangRaw = LanguageType.allCases.first(where: { $0.displayName == filter.targetLanguage })?.rawValue
        let targetLangLevelRaw = LanguageLevelType.allCases.first(where: { $0.displayName == filter.targetLanguageLevel})?.rawValue
        
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
        Task {
            await fetchUserAsync()
        }
        
        print("📮 서버로 날아가는 진짜 데이터: \(request.toDictionary())")
    }
    
    //MARK: - Filter Actions
    
    func applyFilter(_ newFilter: FilterModel) {
        filter = newFilter
        
        if let location = LocationManager.shared.currentLocation {
            fetchRecommendations(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } else {
            print("⚠️ 위치 정보 없음")
        }
    }
    
    var groupedInterests: [InterestGroup] {
        let all = InterestType.allCases
        return [
            InterestGroup(category: "일상 · 라이프스타일", items: Array(all[0...9])),
            InterestGroup(category: "문화 · 콘텐츠", items: Array(all[10...20])),
            InterestGroup(category: "지식 · 시사", items: Array(all[21...31]))
        ]
    }
    
    //MARK: - User Actions
    
    func handleLikeAction() {
        guard let targetUser = currentUser else { return }
    
        Task {
            do {
                try await RecommendationService.shared.sendUserAction(
                    targetId: targetUser.id,
                    action: .like
                )
            } catch {
                print("Like API Error: \(error)")
            }
        }
        presentMatchView()
    }

    func handleSkipAction() {
        guard let targetUser = currentUser else { return }

        Task {
            do {
                try await RecommendationService.shared.sendUserAction(
                    targetId: targetUser.id,
                    action: .skip
                )
            } catch {
                print("Skip API Error: \(error)")
            }
        }
        moveToNextUser()
    }

    private func moveToNextUser() {
        if currentIndex < allUsers.count - 1 {
            currentIndex += 1
            currentUser = allUsers[currentIndex]
        } else {
            status = .finished
        }
    }
    
    func resetDiscovery() {
        currentIndex = 0
        currentUser = allUsers.first
        status = allUsers.isEmpty ? .finished : .idle
    }
    
    //MARK: - Report & Block
    
    func finalizeReportProcess() {
        withAnimation(.easeInOut) {
            reportVM.closeReportMenu()
            self.handleSkipAction()
            self.dismissMatchView()
        }
    }
    
    //MARK: - View Presentation
    
    func presentDetailView() {
        isDetailViewPresented = true
    }

    func dismissDetailView() {
        isDetailViewPresented = false
    }

    func presentMatchView() {
        isMatchViewPresented = true
    }
    
    func dismissMatchView() {
        isMatchViewPresented = false
        reportVM.closeReportMenu()
    }

    func dismissFilterView() {
        isFilterViewPresented = false
    }

    func presentFilterView() {
        isFilterViewPresented = true
    }
}

//MARK: - Helper Struct

extension HomeViewModel {
    struct InterestGroup: Identifiable {
        let id = UUID()
        let category: String
        let items: [InterestType]
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
