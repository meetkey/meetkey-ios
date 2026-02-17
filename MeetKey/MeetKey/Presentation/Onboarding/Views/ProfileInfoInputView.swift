import SwiftUI

struct ProfileInfoInputView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    let genders = ["남자", "여자"]
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack { Spacer() }.frame(height: 44)
                
                // Step 1 페이지네이션 2단계
                OnboardingPagination(currentStep: 2)
                
                // Step 2 타이틀
                OnboardingTitleView(
                    title: "기본 정보를 입력해주세요.",
                    subTitle: "안전한 커뮤니티를 만들기 위한 정보이니\n실제 정보에 맞게 입력해 주세요."
                )
                
                // Step 3 입력 폼 영역
                VStack(spacing: 24) {
                    
                    // A 이름 입력
                    VStack(alignment: .leading, spacing: 10) {
                        LabelWithStar(text: "이름")
                        
                        TextField("", text: $viewModel.data.name)
                            .font(.custom("Pretendard-Regular", size: 16))
                            .foregroundColor(Color.meetKey.text4)
                            .padding(.leading, 20)
                            .padding(.trailing, 14)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.meetKey.black04, lineWidth: 1)
                            )
                            .overlay(alignment: .leading) {
                                if viewModel.data.name.isEmpty {
                                    Text("이름을 입력하세요.")
                                        .font(.custom("Pretendard-Regular", size: 16))
                                        .foregroundColor(Color.meetKey.text4)
                                        .padding(.leading, 20)
                                        .allowsHitTesting(false)
                                }
                            }
                    }
                    
                    // B 생년월일 입력
                    VStack(alignment: .leading, spacing: 10) {
                        LabelWithStar(text: "생년월일")
                        
                        Button(action: {
                            viewModel.isDatePickerPresented = true
                        }) {
                            HStack {
                                Text(viewModel.birthdayDisplayString)
                                    .font(.custom("Pretendard-Regular", size: 16))
                                    .foregroundColor(Color.meetKey.text4)
                                
                                Spacer()
                                
                                Image("icon_calendar")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                            }
                            .padding(.leading, 20)
                            .padding(.trailing, 14)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.meetKey.black04, lineWidth: 1)
                            )
                        }
                    }
                    
                    // C 성별 선택
                    VStack(alignment: .leading, spacing: 10) {
                        LabelWithStar(text: "성별")
                        
                        HStack(spacing: 10) {
                            ForEach(genders, id: \.self) { gender in
                                let isSelected = (viewModel.data.gender == gender)
                                
                                Button(action: {
                                    viewModel.data.gender = gender
                                }) {
                                    Text(gender)
                                        .font(isSelected ? .custom("Pretendard-SemiBold", size: 16) : .custom("Pretendard-Medium", size: 16))
                                        .foregroundColor(isSelected ? Color.meetKey.main : Color.meetKey.text4)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 56)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(isSelected ? Color.meetKey.sub1 : Color.white)
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .strokeBorder(isSelected ? Color.meetKey.main : Color.meetKey.black04, lineWidth: isSelected ? 1.5 : 1)
                                        )
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Step 4 다음 버튼 사진 등록 화면 이동
                NavigationLink(destination: ProfileImageUploadView(viewModel: viewModel)) {
                    Text("다음")
                        .font(.custom("Pretendard-SemiBold", size: 16))
                        .foregroundColor(Color.meetKey.white01)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isProfileInfoCompleted ? Color.meetKey.main : Color.meetKey.black04)
                        .cornerRadius(15)
                }
                .disabled(!viewModel.isProfileInfoCompleted)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            
            // Date 선택 시트
            .sheet(isPresented: $viewModel.isDatePickerPresented) {
                if #available(iOS 16.0, *) {
                    VStack {
                        DatePicker(
                            "생년월일 선택",
                            selection: Binding(
                                get: { viewModel.birthday ?? Date() },
                                set: { viewModel.birthday = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding()
                        .presentationDetents([.medium])
                    }
                } else {
                    DatePicker("", selection: Binding(get: { viewModel.birthday ?? Date() }, set: { viewModel.birthday = $0 }), displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .navigationTitle("")
    }
}

// Component 라벨
struct LabelWithStar: View {
    let text: String
    var body: some View {
        HStack(spacing: 2) {
            Text(text).font(.custom("Pretendard-SemiBold", size: 16)).foregroundColor(Color.meetKey.text1)
            Text("*").font(.custom("Pretendard-SemiBold", size: 16)).foregroundColor(Color.meetKey.main)
        }
    }
}

#Preview {
    ProfileInfoInputView(viewModel: OnboardingViewModel())
}
