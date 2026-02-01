import SwiftUI

struct ProfileImageUploadView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // 1. 페이지네이션 (3단계)
                OnboardingPagination(currentStep: 3)
                
                // 2. 타이틀
                OnboardingTitleView(
                    title: "프로필을 등록해주세요.",
                    subTitle: "실제 사진은 안전한 커뮤니티 조성에 도움이 됩니다.\n본인을 잘 나타내는 사진 3장을 등록해 주세요."
                )
                
                // 3. 사진 등록 그리드 (HStack + VStack)
                HStack(alignment: .top, spacing: 10) {
                    // [왼쪽 열] 작은 사진 1, 2
                    VStack(spacing: 10) {
                        ProfileImageSlot(
                            title: "대표사진 1",
                            image: viewModel.profileImages[0],
                            height: 172
                        ) {
                            handleSlotTap(index: 0)
                        }
                        
                        ProfileImageSlot(
                            title: "대표사진 2",
                            image: viewModel.profileImages[1],
                            height: 172
                        ) {
                            handleSlotTap(index: 1)
                        }
                    }
                    .frame(width: 172)
                    
                    // [오른쪽 열] 긴 사진 3
                    ProfileImageSlot(
                        title: "대표사진 3",
                        image: viewModel.profileImages[2],
                        height: 354
                    ) {
                        handleSlotTap(index: 2)
                    }
                    .frame(width: 172)
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // 4. 다음 버튼 NavigationLink 연결
                NavigationLink(destination: InterestSelectionView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(.meetKeyWhite01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isProfileImagesCompleted ? Color.meetKeyOrange04 : Color.meetKeyBlack04)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.isProfileImagesCompleted) // 3장 다 안 채우면 비활성화
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // [커스텀 바텀 시트]
            if viewModel.showImageActionSheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.showImageActionSheet = false }
                
                VStack {
                    Spacer()
                    CustomImageActionSheet(viewModel: viewModel)
                        .transition(.move(edge: .bottom))
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
        // 시스템 이미지 피커
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(
                image: Binding(
                    get: { nil },
                    set: { img in
                        if let img = img, let index = viewModel.selectedImageIndex {
                            viewModel.profileImages[index] = img
                        }
                    }
                ),
                sourceType: viewModel.imagePickerSource
            )
        }
    }
    
    func handleSlotTap(index: Int) {
        viewModel.selectedImageIndex = index
        withAnimation {
            viewModel.showImageActionSheet = true
        }
    }
}

// [컴포넌트] 사진 등록 박스 (Slot)
struct ProfileImageSlot: View {
    let title: String
    let image: UIImage?
    let height: CGFloat
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.meetKeyBlack07)
                
                if let uImage = image {
                    Image(uiImage: uImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 172, height: height)
                        .clipped()
                        .cornerRadius(12)
                } else {
                    // 이미지가 없을 때
                    VStack(spacing: 8) {
                        Image("icon_plus")
                            .resizable()
                            .frame(width: 24, height: 24)
                        
                        Text(title)
                            .font(.custom("Pretendard-Regular", size: 16))
                            .foregroundColor(.meetKeyBlack03)
                    }
                }
            }
            .frame(width: 172, height: height)
        }
    }
}

// [컴포넌트] 커스텀 액션 시트
struct CustomImageActionSheet: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // 핸들 바
            Capsule()
                .fill(Color.meetKeyBlack02)
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 20)
            
            // 타이틀
            Text("사진 올리기")
                .font(.custom("Pretendard-Bold", size: 18))
                .foregroundColor(.meetKeyBlack01)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 24)
                .padding(.bottom, 20)
            
            // 메뉴 1: 사진첩
            Button(action: {
                viewModel.imagePickerSource = .photoLibrary
                viewModel.showImageActionSheet = false
                viewModel.showImagePicker = true
            }) {
                HStack {
                    Image("icon_image")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("내 사진첩에서 고르기")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(.meetKeyBlack03)
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.meetKeyBlack03)
                }
                .padding(.horizontal, 24)
                .frame(height: 56)
            }
            
            // 메뉴 2: 카메라
            Button(action: {
                viewModel.imagePickerSource = .camera
                viewModel.showImageActionSheet = false
                viewModel.showImagePicker = true
            }) {
                HStack {
                    Image("icon_camera")
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    Text("카메라로 등록하기")
                        .font(.custom("Pretendard-Medium", size: 16))
                        .foregroundColor(.meetKeyBlack03)
                    
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.meetKeyBlack03)
                }
                .padding(.horizontal, 24)
                .frame(height: 56)
            }
            
            // 닫기 버튼
            Button(action: {
                withAnimation {
                    viewModel.showImageActionSheet = false
                }
            }) {
                Text("닫기")
                    .font(.custom("Pretendard-SemiBold", size: 16))
                    .foregroundColor(.meetKeyWhite01)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color.meetKeyOrange04)
                    .cornerRadius(15)
            }
            .padding(24)
        }
        .background(Color.white)
        .cornerRadius(20, corners: [.topLeft, .topRight])
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ProfileImageUploadView(viewModel: OnboardingViewModel())
}
