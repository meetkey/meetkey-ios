//
//  UserStore.swift
//  MeetKey
//
//  Created by sumin Kong on 2/5/26.
//

import Foundation
import Combine

final class UserStore: ObservableObject {
    @Published var user: User

    init(user: User) {
        self.user = user
    }
}
