//
//  HomeViewModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Combine
import Foundation
import SwiftUI



class HomeViewModel: ObservableObject {
    
    //MARK: - 1. Global State & 홈뷰에서 다뤄야하는 로직 (남길 것)
    @Published var me = User.me  // 로그인한 유저
    @Published var selectedUser: User?  // 디테일 뷰에 넘겨주기 위함
    @Published var isDetailViewPresented: Bool = false
    @Published var isFilterViewPresented: Bool = false
    
    
    //MARK: - 2. 매칭 로직을 위한 아이들 -> 분리..할 예정
    @Published private(set) var currentIndex: Int = 0
    @Published var isMatchViewPresented: Bool = false
    @Published var hasReachedLimit: Bool = false
    let users: [User] = User.mockData  //확인용 더미데이터
    
    //MARK: -3 Report & Block
    @Published var reportVM = ReportViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        reportVM.objectWillChange
                    .sink { [weak self] _ in
                        // 📢 자식이 바뀌면 부모(나)도 "나 바뀌었어!"라고 외칩니다.
                        self?.objectWillChange.send()
                    }
                    .store(in: &cancellables) // 주머니에 안테나 선 저장
                    
                // ✅ 비서가 일이 다 끝났다고(onFinalize) 보고할 때의 로직도 여기서 관리!
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

    //MARK: - 2
    var currentUser: User? {
        guard users.indices.contains(currentIndex) else { return nil }
        return users[currentIndex]
    }

    func handleLikeAction() {  //스와이프 or 관심있음 버튼 -> 매칭화면
        presentMatchView()
    }

    func handleSkipAction() {  //스와이프 or 관심없음 버튼 -> 다음화면
        incrementUserIndex()
    }
    
    func resetDiscovery() {
        currentIndex = 0
        hasReachedLimit = false
    }
    
    private func incrementUserIndex() {
        if currentIndex >= users.count - 1 {
            hasReachedLimit = true  // 추천친구 끝
        } else {
            currentIndex += 1
        }
    }

    //MARK: - 1
    func handleFilterAction() {
        presentFilterView()
    }

    func handleFilterDismissAction() {
        dismissFilterView()
    }



    func presentDetailView() {
        isDetailViewPresented = true
    }

    func dismissDetailView() {
        isDetailViewPresented = false
    }
    
    private func presentMatchView() {
        isMatchViewPresented = true
    }

    private func dismissFilterView() {
        isFilterViewPresented = false
    }

    private func presentFilterView() {
        isFilterViewPresented = true
    }
}


// MARK: - 유저 목데이터
extension User {
    static let mockData: [User] = [
        User(
            id: UUID(),
            name: "전효빈",
            age: 27,
            bio: "iOS 개발자가 되고 싶은 사람입니다. SwiftUI 최고!",
            profileImageURL: "profileImageSample1",
            safeBadge: .gold
        ),
        User(
            id: UUID(),
            name: "김민준",
            age: 24,
            bio: "주말마다 한강에서 러닝하는 거 좋아해요. 같이 뛰실 분?",
            profileImageURL: "profileImageSample2",
            safeBadge: .silver
        ),
        User(
            id: UUID(),
            name: "이서연",
            age: 29,
            bio: "카페 투어와 사진 촬영이 취미입니다. 기록하는 걸 좋아해요.",
            profileImageURL: "profileImageSample1",
            safeBadge: .bronze
        ),
        User(
            id: UUID(),
            name: "박지성",
            age: 31,
            bio: "개발자입니다. 커피 한 잔 하면서 기술 얘기 나누고 싶어요.",
            profileImageURL: "profileImageSample2",
            safeBadge: .none
        ),
        User(
            id: UUID(),
            name: "최유진",
            age: 24,
            bio: "이제 막 대학교 졸업했어요! 새로운 사람들을 만나는 건 늘 설레네요.",
            profileImageURL: "profileImageSample1",
            safeBadge: .gold
        ),
    ]

    //로그인 유저 목데이터
    static let me = User(
        id: UUID(),
        name: "김밋키",
        age: 24,
        bio: "안녕하세요, 언어 교환 친구를 사귀고 싶어요",
        profileImageURL: "profileImageSample1",
        safeBadge: .gold
    )
}
