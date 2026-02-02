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
    
    //MARK: - 3. Report & Block State -> 이동 예정
    @Published var isReportMenuPresented: Bool = false  // 채팅(매칭)에서 신고
    @Published var currentReportStep: ReportStep = .none

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

    func dismissMatchView() {  // dismiss 대신
        isMatchViewPresented = false
        isReportMenuPresented = false
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

    //MARK: -- 3. Report & Block 처리 로직
    //2. handleReportMenuTap
    func handleReportMenuTap() {
        withAnimation(.spring()) {
            if isReportMenuPresented {
                closeReportMenu()
            } else {
                isReportMenuPresented = true
                currentReportStep = .main  // 열 때 기본 메뉴부터
            }
        }
    }

    //  3. 메뉴 단계 전환 함수 추가
    func changeReportStep(to step: ReportStep) {
        withAnimation(.easeInOut) {
            isReportMenuPresented = false
            currentReportStep = step
        }
    }

    //  4. 메뉴 닫기 함수 추가
    func closeReportMenu() {
        withAnimation {
            isReportMenuPresented = false
            currentReportStep = .none
        }
    }
    
    //  5. 프로세스 종료 함수
    func finalizeReportProcess() {
        withAnimation(.easeInOut) {
            self.isReportMenuPresented = false
            self.currentReportStep = .none
            self.handleSkipAction()
            self.dismissMatchView()
        }
    }

    //  6. 실제 비즈니스 로직 처리 함수 (틀만 잡아두기) TODO: API 연결
    func confirmBlock() {
        guard let user = currentUser else { return }
        print("\(user.name) 차단 완료")
        
        withAnimation {
            self.currentReportStep = .blockComplete
        }
    }
    
    func confirmReport() {
        guard let user = currentUser else { return}
        print("\(user.name) 신고 완료")
        
        withAnimation {
            self.currentReportStep = .reportComplete
        }
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
