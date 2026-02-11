//
//  BlockService.swift
//  MeetKey
//
//  Created by 전효빈 on 2/12/26.
//

class BlockService {
    static let shared = BlockService()
    private let networkProvider = NetworkProvider.shared
    private init() {}

    func blockUser(targetId: Int) async throws {
        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            networkProvider.requestBlock(
                .blockUser(memberId: targetId),
                type: BlockResponse.self
            ) { result in
                switch result {
                case .success(let response):
                    print("✅ 유저 차단 성공: \(targetId)")
                    continuation.resume()

                case .failure(let error):
                    print("❌ 유저 차단 실패: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

struct BlockResponse: Codable {
    let code: String
    let message: String
    let data: BlockData
}

struct BlockData: Codable {
    let fromMemberId: Int
    let toMemberId: Int
}
