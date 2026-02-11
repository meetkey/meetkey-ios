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
//MARK: - 비동기 작업을 위한 Enum
enum HomeStatus {
    case loading  // 기본
    case idle  // 유저 카드를 보여주는 기본 상태
    case matching  // 매칭 액션 이후
    case finished  // 매칭 성공 화면
    //    case error
    //    다른 것은 차차 추가 할 예정
}

@MainActor
class HomeViewModel: ObservableObject {
    //MARK: - [상태 관리]
    @Published var status: HomeStatus = .loading
    @Published var filter = FilterModel()

    //MARK: - [데이터]
    @Published var me = User.me  // 로그인한 유저
    @Published var allUsers: [User] = []  // 기존 users
    @Published var currentUser: User?  // 기존 selectedUser
    @Published private(set) var currentIndex: Int = 0
    private let locationManager = LocationManager.shared

    //MARK: - [화면 제어]
    @Published var isDetailViewPresented: Bool = false
    @Published var isFilterViewPresented: Bool = false
    @Published var isMatchViewPresented: Bool = false
    @Published var hasReachedLimit: Bool = false

    let users: [User] = User.mockData  //확인용 더미데이터

    //MARK: - 서비스 주입
    @Published var currentFilter = RecommendationRequest()

    private let recommendationService = RecommendationService.shared

    //MARK: -3 Report & Block
    @Published var reportVM = ReportViewModel()

    private var cancellables = Set<AnyCancellable>()

    init() {
        reportVM.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)

        reportVM.onFinalize = { [weak self] in
            self?.finalizeReportProcess()
        }
        
        locationManager.$currentLocation
                    .compactMap { $0 }
                    .first() // 첫 번째만 받고 구독 해제
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

    //MARK: -3
    func finalizeReportProcess() {
        withAnimation(.easeInOut) {
            reportVM.closeReportMenu()

            self.handleSkipAction()
            self.dismissMatchView()
        }
    }

    func dismissMatchView() {
        isMatchViewPresented = false
        reportVM.closeReportMenu()
    }

    //MARK: 유저
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

    //MARK: - 필터
    func fetchRecommendations(latitude: Double, longitude: Double) {
        // 1. 관심사 한글 배열 -> 서버용 영어 rawValue 배열로 변환
        let interestsRaw = filter.interests?.compactMap { korName in
            InterestType.allCases.first(where: { $0.displayName == korName })?.rawValue
        }
        
        // 2. 성향(Personality) 한글 배열 -> 서버용 영어 rawValue 배열로 변환
        let personalityRaw: [String] = filter.combinedPersonalities ?? []
        
        // 3. 국적, 언어 등 단일 선택 항목 변환
        let hometownRaw = NationalityType.allCases.first(where: { $0.displayName == filter.hometown })?.rawValue
        let nativeLangRaw = LanguageType.allCases.first(where: { $0.displayName == filter.nativeLanguage })?.rawValue
        let targetLangRaw = LanguageType.allCases.first(where: { $0.displayName == filter.targetLanguage })?.rawValue
        let targetLangLevelRaw = LanguageLevelType.allCases.first(where: { $0.displayName == filter.targetLanguageLevel})?.rawValue
        
        // 4. 변환된 'Raw' 데이터들로 요청서 작성
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
    func applyFilter(_ newFilter: FilterModel) {
        filter = newFilter
//        fetchRecommendations(latitude: 37.5665, longitude: 126.9780)
        
        // 현재 위치로 API 요청
        if let location = LocationManager.shared.currentLocation {
            fetchRecommendations(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
        } else {
            print("⚠️ 위치 정보 없음")
        }
    }

    struct InterestGroup: Identifiable {
        let id = UUID() // ForEach가 식별할 수 있게 해줌
        let category: String
        let items: [InterestType]
    }

    // ViewModel의 프로퍼티 수정
    var groupedInterests: [InterestGroup] {
        let all = InterestType.allCases
        // 인덱스 기반 슬라이싱 (모델 순서대로)
        return [
            InterestGroup(category: "일상 · 라이프스타일", items: Array(all[0...9])),
            InterestGroup(category: "문화 · 콘텐츠", items: Array(all[10...20])),
            InterestGroup(category: "지식 · 시사", items: Array(all[21...31]))
        ]
    }

    //MARK: - Like 액션
    func handleLikeAction() async {
        guard let targetUser = currentUser else { return }

        print("DEBUG: \(targetUser.name)님")
        do {
            // try await networkManager.sendLike(to: targetUser.id)
            try await Task.sleep(nanoseconds: 500_000_000)

            presentMatchView()  // 성공 시 매칭 화면

        } catch {
            print("Like 처리 실패: \(error)")
        }
    }

    //MARK: - Skip/Next 액션
    func handleSkipAction() {
        if currentIndex < allUsers.count - 1 {
            currentIndex += 1
            currentUser = allUsers[currentIndex]
        } else {
            self.status = .finished
        }
    }

    func resetDiscovery() {
        currentIndex = 0
        currentUser = allUsers.first
        status = allUsers.isEmpty ? .finished : .idle
    }

    //MARK: - 1

    func presentDetailView() {
        isDetailViewPresented = true
    }

    func dismissDetailView() {
        isDetailViewPresented = false
    }

    func presentMatchView() {
        isMatchViewPresented = true
    }

    func dismissFilterView() {
        isFilterViewPresented = false
    }

    func presentFilterView() {
        isFilterViewPresented = true
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
