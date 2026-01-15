//
//  HybinHomeView.swift
//  
//
//  Created by 전효빈 on 1/15/26.
//

//피그마 홈 뷰 제작
import SwiftUI

struct HybinHomeView : View {
    @State private var users: [String] = ["One", "Two", "Three", "Four", "Five"]
    @State private var currentIndex: Int = 0
    @State private var safeBadge = "gold"
    
    var body : some View {
        GeometryReader { geometry in
            let imageWidth = geometry.size.width * 0.76
            let imageHeight = imageWidth * (536.0 / 304.0)
            let imageSize = CGSize(width: imageWidth, height: imageHeight)
            
            ZStack{
                
                VStack{
                    Header
                    
                    Spacer()
                    
                    ZStack(alignment: .bottom){
                        
                        HybinProfileSectionView(
                            size: imageSize,
                            name: users[currentIndex],
                            badge: safeBadge
                        )
                        
                        likeButton
                            .offset(y: imageHeight * 0.01)
                    }
                    .frame(width:imageWidth, height: imageHeight)
                    
                    Spacer()
                }
            }
        }
    }
    
    //MARK: - Header (Logo and Filter)
    private var Header: some View {
        HStack {
            appLogoTitleView
            Spacer()
            filterButton
        }
    }

    // MARK: - 앱 로고 타이틀 뷰
    private var appLogoTitleView: some View {
        HStack {
            Text("logo")
        }
    }
    
    //MARK: -필터 버튼
    private var filterButton: some View{
        Button(action: {
            print("filter")
        }) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 20))
                .foregroundStyle(Color.black)
        }
    }
    
    // MARK: - 관심 버튼
    private var likeButton : some View{
        HStack{
            Button {
                print("unlike")
            } label:{
                Text("unlike")
            }
            
            Spacer()
            
            Button {
                print("like")
            } label: {
                Text("like")
            }
        }
    }
    

}


#Preview {
    HybinHomeView()
}
