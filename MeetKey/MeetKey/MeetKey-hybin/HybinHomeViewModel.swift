//
//  HybinHomeViewModel.swift
//  MeetKey
//
//  Created by 전효빈 on 1/22/26.
//

import Combine
import Foundation
import SwiftUI

enum ReportStep{
    case none
    case main
    case block
    case blockComplete
    case report
    case reportCase
    case reportReason
    case reportComplete
}

class HybinHomeViewModel: ObservableObject {
    @Published private(set) var currentIndex: Int = 0
    @Published var showMatchView: Bool = false
    @Published var showFilterView: Bool = false
    @Published var showDetailExpander: Bool = false
    @Published var selectedUser: User?  // 디테일 뷰에 넘겨주기 위함
    @Published var hasReachedLimit: Bool = false
    @Published var showReportMenu: Bool = false  // 채팅(매칭)에서 신고하기
    @Published var me = User.me  // 로그인한 유저
    @Published var currentReportStep: ReportStep = .none

    let users: [User] = User.mockData  //확인용 더미데이터

    var currentUser: User? {
        guard users.indices.contains(currentIndex) else { return nil }
        return users[currentIndex]
    }

    func didSelectLike() {  //스와이프 or 관심있음 버튼 -> 매칭화면
        showMatch()
    }

    func didSelectUnlike() {  //스와이프 or 관심없음 버튼 -> 다음화면
        moveToNextUser()
    }

    func didSelectFilter() {
        showFilter()
    }

    func didSelectHome() {
        goHome()
    }

    func didFinishMatch() {  // dismiss 대신
        showMatchView = false
        showReportMenu = false
    }

    func didTapDetail() {
        showDetailExpander = true
    }

    func didTapBackFromDetail() {
        showDetailExpander = false
    }

    func resetDiscovery() {
        currentIndex = 0
        hasReachedLimit = false
    }
    
    //2. didTapReport 수정 (토글 방식으로)
        func didTapReport() {
            withAnimation(.spring()) {
                if showReportMenu {
                    closeReportMenu()
                } else {
                    showReportMenu = true
                    currentReportStep = .main // 열 때 기본 메뉴부터
                }
            }
        }

        //  3. 메뉴 단계 전환 함수 추가
        func changeReportStep(to step: ReportStep) {
            withAnimation(.easeInOut) {
                currentReportStep = step
            }
        }

        //  4. 메뉴 닫기 함수 추가
        func closeReportMenu() {
            withAnimation {
                showReportMenu = false
                currentReportStep = .none
            }
        }

        //  5. 실제 처리 함수 (틀만 잡아두기)
        func confirmBlock() {
            guard let user = currentUser else { return }
            print("\(user.name) 차단 완료")
            closeReportMenu()
            moveToNextUser() // 차단했으니 다음 사람으로 넘기기
        }

    private func showMatch() {
        showMatchView = true
    }

    private func moveToNextUser() {
        if currentIndex >= users.count - 1 {
            hasReachedLimit = true  // 추천친구 끝
        } else {
            currentIndex += 1
        }
    }

    private func goHome() {
        showFilterView = false
    }

    private func showFilter() {
        showFilterView = true
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
