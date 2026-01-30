//
//  HybinFinishedMatchView.swift
//  MeetKey
//
//  Created by 전효빈 on 1/30/26.
//

import SwiftUI

struct HybinFinishedMatchView: View {
//    @ObservedObject var homeVM : HybinHomeViewModel
//    let size : CGSize
//    let safeArea: EdgeInsets
    
    var body: some View {
        
        VStack{
            //meetkeyImage
            //description
            HStack{
                //Group{Button}
            }
        }
        Text("Hello, World!")
    }
    
    private var contentBody : some View{
        VStack{
            //Image
            //오늘의 추천 완료!
            //내일 새로운 친구들을 만나보세요.
        }
    }
    
    private var discoverButton: some View {
        HStack{
            Group{
                //button 처음으로와 자세히보기
            }
        }
    }
    private var descriptionView: some View{
        VStack{
            HStack{ //친구 추천을 더 받고 싶나요? 와 이미지
                
            }
            //description Text
        }
    }
}

#Preview {
    HybinFinishedMatchView()
}
