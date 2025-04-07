@testable import GravatarUI
import Testing

struct KeychainTokenTests {
    @Test
    func testKeychainTokenCreatedFromData() async throws {
        let token = KeychainToken(token: "someToken")
        let data = token.data
        #expect(data != nil)

        let decodedToken = KeychainToken(data: data!)
        #expect(decodedToken?.token == token.token)
        #expect(decodedToken?.isExpired == token.isExpired)
    }

    @Test
    func testExpiredKeychainTokenCreatedFromData() async throws {
        var token = KeychainToken(token: "someToken")
        token.isExpired = true

        let data = token.data
        #expect(data != nil)

        let decodedToken = KeychainToken(data: data!)
        #expect(decodedToken?.token == token.token)
        #expect(decodedToken?.isExpired == true)
    }
}
