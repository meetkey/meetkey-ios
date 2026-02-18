import Foundation
import Security

// Token 저장용 Keychain 헬퍼
enum KeychainManager {
    static func save(value: String, account: String) throws {
        if value.isEmpty {
                print("❌ [KEYCHAIN DEBUG] 저장 실패: '\(account)'에 넣으려는 값이 빈 문자열입니다.")
                return
            }
        
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "MeetKey",
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
        ]

        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        if status == errSecSuccess {
            print("✅ [KEYCHAIN DEBUG] '\(account)' 저장 성공")
        } else {
            print("❌ [KEYCHAIN DEBUG] '\(account)' 저장 실패 (Status: \(status))")
            throw NSError(domain: "Keychain", code: Int(status), userInfo: nil)
        }
    }

    static func read(account: String) throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: "MeetKey",
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
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
        let result = try? read(account: account)
        if result == nil {
            print("⚠️ [KEYCHAIN DEBUG] '\(account)' 로드 실패 혹은 데이터 없음")
        }
        return result
    }
}
