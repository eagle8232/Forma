import Foundation
import FirebaseAuth
import GoogleSignIn

final class AuthRepository: AuthRepositoryProtocol {
    
    fileprivate var isAnonymous: Bool = false
    
    func signIn(with authProvider: AuthProvider) async throws -> UserCredentials? {
        guard let result = try await authProviderSetup(with: authProvider) else {
            print("Could not create Firebase credentials")
            return nil
        }
        
        return UserCredentials(
            id: result.user.uid,
            name: result.user.displayName ?? "Unknown name",
            email: result.user.email ?? "Unknown name",
            isAnonymous: isAnonymous
        )
    }
    
    func signUp(with authProvider: AuthProvider) async throws -> UserCredentials? {
        guard let result = try await authProviderSetup(with: authProvider) else {
            print("Could not create Firebase credentials")
            return nil
        }
        
        return UserCredentials(
            id: result.user.uid,
            name: result.user.displayName ?? "Unknown name",
            email: result.user.email ?? "Unknown name",
            isAnonymous: isAnonymous
        )
    }
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    func deleteUser() async throws {
        guard let currentUser = Auth.auth().currentUser else { return }
        try await currentUser.delete()
    }
    
    fileprivate func authProviderSetup(with authProvider: AuthProvider) async throws -> AuthDataResult? {
        switch authProvider {
        case .google(let token, let accessToken):
            let credential = GoogleAuthProvider.credential(withIDToken: token, accessToken: accessToken)
            return try await Auth.auth().signIn(with: credential)
        case .apple(let token, _):
            let credential = OAuthProvider.credential(providerID: .apple, idToken: token)
            return try await Auth.auth().signIn(with: credential)
        case .anonymous:
            isAnonymous = true
            return try await Auth.auth().signInAnonymously()
        }
    }
    
    fileprivate func mapAuthError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        if nsError.code == 17008 { return .invalidCredential }
        return .missingUserData
    }
}
