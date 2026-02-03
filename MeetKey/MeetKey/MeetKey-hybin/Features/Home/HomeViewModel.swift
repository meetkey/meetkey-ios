//
//  HomeViewModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Combine
import Foundation
import SwiftUI

//MARK: - 비동기 작업을 위한 Enum
enum HomeStatus {
    case loading  // 기본
    case idle  // 유저 카드를 보여주는 기본 상태
    case matching  // 매칭 액션 이후
    case finished // 매칭 성공 화면
    //    case error
    //    다른 것은 차차 추가 할 예정
}

@MainActor
class HomeViewModel: ObservableObject {
    //MARK: - [상태 관리]
    @Published var status: HomeStatus = .loading

    //MARK: - [데이터]
    @Published var me = User.me  // 로그인한 유저
    @Published var allUsers: [User] = []  // 기존 users
    @Published var currentUser: User?  // 기존 selectedUser
    @Published private(set) var currentIndex: Int = 0

    //MARK: - [화면 제어]
    @Published var isDetailViewPresented: Bool = false
    @Published var isFilterViewPresented: Bool = false
    @Published var isMatchViewPresented: Bool = false
    @Published var hasReachedLimit: Bool = false

    let users: [User] = User.mockData  //확인용 더미데이터

    //MARK: -3 Report & Block
    @Published var reportVM = ReportViewModel()

    private var cancellables = Set<AnyCancellable>()

    init() {
        reportVM.objectWillChange
            .sink { [weak self] _ in
                // 자식이 바뀌면 부모(나)도 "나 바뀌었어!"라고 외칩니다.
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)  // 주머니에 안테나 선 저장

        // 비서가 일이 다 끝났다고(onFinalize) 보고할 때의 로직도 여기서 관리!
        reportVM.onFinalize = { [weak self] in
            self?.finalizeReportProcess()
        }
    }

    //MARK: -3
    func finalizeReportProcess() {
        withAnimation(.easeInOut) {
            // 1. reportVM의 메뉴 닫기, 스텝 초기화
            reportVM.closeReportMenu()

            // 2. homeVM의 카드 넘기기, 매칭창 닫기 받기
            self.handleSkipAction()
            self.dismissMatchView()
        }
    }

    func dismissMatchView() {  // dismiss 대신
        isMatchViewPresented = false
        reportVM.closeReportMenu()
    }

    //MARK: 초기 데이터 로드
    func fetchUserAsync() async {
        status = .loading
        
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000)
            
            let fetchedData = User.mockData // API 호출 할거임
            
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
    
    //MARK: - Like 액션
    func handleLikeAction() async {
        guard let targetUser = currentUser else { return }
        
        print("DEBUG: \(targetUser.name)님")
        do {
            // try await networkManager.sendLike(to: targetUser.id)
            try await Task.sleep(nanoseconds: 500_000_000)
            
            presentMatchView() // 성공 시 매칭 화면

        } catch {
            print("Like 처리 실패: \(error)")
        }
    }
    
    //MARK: - Skip/Next 액션
    func handleSkipAction() { //나중에 비동기로?
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
            memberId: 101,
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
            memberId: 102,
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
            memberId: 103,
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
            memberId: 104,
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
            memberId: 105,
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
        memberId: 1,
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
        recommendCount: 0,
        notRecommendCount: 0,
        interests: ["Language Exchange"],
        personalities: nil,
        badge: BadgeInfo(badgeName: "골드 뱃지", totalScore: 99, histories: nil),
        birthDate: nil
    )
}
