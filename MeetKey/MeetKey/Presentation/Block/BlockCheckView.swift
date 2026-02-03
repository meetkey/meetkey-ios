//
//  BlockCheckView.swift
//  MeetKey
//
//  Created by sumin Kong on 2/2/26.
//

import SwiftUI

struct BlockCheckView: View {
    var body: some View {
        ZStack {
            Image(.imgCharMeetkey02)
                .padding(.leading, 89)
            
            VStack(alignment: .leading,spacing: 0) {
                HStack(spacing: 4) {
                    Image(.tickSquare)
                    Text("차단하기")
                        .font(.meetKey(.title4))
                        .foregroundStyle(.black01)
                        .frame(height: 31)
                    Spacer()
                }
                .padding(.leading, 2)
                
                Text("상대방을 차단했습니다.\n서로의 프로필을 확인할 수 없으며,\n추천치구 목록에도 표시되지 않습니다.\n\n또한 상대방은 회원님에게\n메시지를 보낼 수 없습니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.black03)
                    .padding(.top, 34)
                Text("상대방을 차단했습니다.")
                    .font(.meetKey(.body3))
                    .foregroundStyle(.black03)
                
                BlockApplyBtn(title: "확인"){
                    
                }
                .padding(.top, 103)
            }
            .padding(.horizontal, 23)
        }
        
    }
}
