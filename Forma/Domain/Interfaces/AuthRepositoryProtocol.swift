import Foundation

enum AuthProvider {
    case google(idToken: String, accessToken: String)
    case apple(token: String, nonce: String)
    case anonymous
}

protocol AuthRepositoryProtocol {
    func signIn(with authProvider: AuthProvider) async throws -> UserCredentials?
    func signUp(with authProvider: AuthProvider) async throws -> UserCredentials?
    func signOut() async throws
    func deleteUser() async throws
}
