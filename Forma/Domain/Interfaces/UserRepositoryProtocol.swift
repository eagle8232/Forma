import Foundation

protocol UserRepositoryProtocol {
    func fetchUser(_ userId: String) async throws -> User?
    func saveUser(_ user: User) async throws
    func deleteUser(_ user: User) async throws
}
