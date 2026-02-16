//
//  OtherProfileView.swift
//  MeetKey
//
//  Created by sumin Kong on 1/30/26.
//

import SwiftUI

struct OtherProfileView2: View {
    
    
    @StateObject private var viewModel = OtherProfileViewModel()
    let targetId: Int
    
    
    
    var body: some View {
//        GeometryReader { geo in
            ZStack(alignment: .top) {
                
                // MARK: - 배경 이미지
//                if let profile = viewModel.profile {
//                    AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                            .clipped()
//                    } placeholder: {
//                        Image(.otherProfile)
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: geo.size.width, height: geo.size.height)
//                            .clipped()
//                    }
//                } else {
//                    Color.gray.opacity(0.2)
//                        .ignoresSafeArea()
//                }
                
                // MARK: - 로딩 인디케이터
                if viewModel.isLoading {
                    ProgressView("프로필 불러오는 중..")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                }
                
                // MARK: - 프로필 상세
                if let profile = viewModel.profile {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            
                            // 상단 네비바 대체 이미지
                            headerView
                                                    }
                        .background(Color.white01)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.top, 38)
                        .padding(.horizontal, 20)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                viewModel.fetchOtherProfile(targetId: targetId)
            }
        }

    }

//}
// MARK: - Private Components
private extension OtherProfileView2 {
    
    private var headerView: some View {
        HeaderOverlay (
            state: .otherProfile,
            user: viewModel.headerUser ?? User.mockData [0], reportVM: viewModel.reportVM,
            onRightAction: {
                viewModel.reportVM.handleReportMenuTap()
            }
        )
        .zIndex(1)
    }
    // 메인 프로필 이미지 + 배지 + 사용자 정보
    @ViewBuilder
    func mainProfileImage(profile: OtherInfoDTO, width: CGFloat) -> some View {
        VStack {
            AsyncImage(url: URL(string: profile.profileImage ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: 350)
                    .clipped()
            } placeholder: {
                Image(.otherProfile)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: 350)
                    .clipped()
            }
        }
        .frame(maxWidth: .infinity)
        // 유저 정보 오버레이 (왼쪽 하단)
        .overlay(
            VStack(alignment: .leading) {
                Spacer()
                userInfoSection(profile: profile)
            }
                .padding(.leading, 16)
                .padding(.bottom, 16),
            alignment: .bottomLeading
        )
        // 배지 오버레이 (오른쪽 하단)
        .overlay(
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if let _ = profile.badge?.badgeName {
                        BadgeView(score: profile.badge?.totalScore ?? 0)
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 16)
            },
            alignment: .bottom
        )
    }
    
    // 사용자 기본 정보 (이름, 나이, 위치, 성별 등)
    @ViewBuilder
    func userInfoSection(profile: OtherInfoDTO) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 0) {
                Text(profile.name)
                    .font(.meetKey(.title2))
                    .foregroundStyle(.white01)
                Text("\(profile.age)")
                    .font(.meetKey(.title6))
                    .foregroundStyle(.white01)
                    .padding(.leading, 4)
            }
            HStack {
                Image(.location)
                Text("\(profile.location), \(profile.distance)")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.background2)
            }
            .padding(.top, 10)
            HStack {
                Image(.moreCircle)
                Text("출신국가 : \(profile.homeTown) / 성별 : \(genderText(profile.gender))")
                    .font(.meetKey(.body5))
                    .foregroundStyle(.background2)
            }
        }
    }
    
    // 배지 뷰
    @ViewBuilder
    func BadgeView(score: Int) -> some View {
        let type = BadgeType1.from(score: score)
        let tagName = type.assetName.replacingOccurrences(of: "Badge", with: "Tag")
        
        Image(tagName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 60, height: 25)
            .padding()
    }
    
    // 성별 텍스트
    func genderText(_ gender: String) -> String {
        gender == "MALE" ? "남성" : "여성"
    }
}


#Preview {
    OtherProfileView2(targetId: 1)
}
