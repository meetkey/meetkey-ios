import Foundation
import Security

// Token 저장용 Keychain 헬퍼
enum KeychainManager {
    static func save(value: String, account: String) throws {
        let data = Data(value.utf8)
        
        // 1. 찾기용 쿼리 (삭제할 때도 사용)
        let searchQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "MeetKey",
            kSecAttrAccount as String: account
        ]

        // 2. 일단 기존 방을 비웁니다 (ValueData 없이 Account로만 검색해서 삭제)
        SecItemDelete(searchQuery as CFDictionary)

        // 3. 저장용 쿼리 (찾기용 쿼리에 실제 데이터(ValueData)만 추가)
        var saveQuery = searchQuery
        saveQuery[kSecValueData as String] = data

        // 4. 새 데이터 추가
        let status = SecItemAdd(saveQuery as CFDictionary, nil)
        
        if status != errSecSuccess {
            print("❌ Keychain 저장 실패: \(status)")
            throw NSError(domain: "Keychain", code: Int(status), userInfo: nil)
        }
    }

    static func read(account: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "MeetKey",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecItemNotFound {
            return nil
        }
        if status != errSecSuccess {
            throw NSError(domain: "Keychain", code: Int(status), userInfo: nil)
        }

        guard let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func load(account: String) -> String? {
        return try? read(account: account)
    }

    static func delete(account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "MeetKey",
            kSecAttrAccount as String: account
        ]
        SecItemDelete(query as CFDictionary)
    }
}
