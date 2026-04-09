import Foundation
import FirebaseAuth
import GoogleSignIn
import AuthenticationServices

final class AuthRepository: AuthRepositoryProtocol {
    
    fileprivate var isAnonymous: Bool = false
    private var lastAuthCredential: AuthCredential?
    
    func signIn(with authProvider: AuthProvider) async throws -> UserCredentials? {
        guard let result = try await authProviderSetup(with: authProvider) else {
            print("Could not create Firebase credentials")
            return nil
        }
        
        lastAuthCredential = result.credential
        
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
        
        lastAuthCredential = result.credential
        
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
        guard let currentUser = Auth.auth().currentUser else {
            throw AuthError.missingUserData
        }
        
        if let googleToken = getGoogleStoredToken() {
            let credential = GoogleAuthProvider.credential(withIDToken: googleToken.idToken, accessToken: googleToken.accessToken)
            try await currentUser.reauthenticate(with: credential)
        } else if let storedCredential = lastAuthCredential {
            try await currentUser.reauthenticate(with: storedCredential)
        } else {
            for providerData in currentUser.providerData {
                if providerData.providerID == GoogleAuthProviderID {
                    throw AuthError.requiresReauthentication
                }
            }
        }
        
        try await currentUser.delete()
    }
    
    private func getGoogleStoredToken() -> (idToken: String, accessToken: String)? {
        guard let user = GIDSignIn.sharedInstance.currentUser else { return nil }
        guard let idToken = user.idToken?.tokenString else { return nil }
        let accessToken = user.accessToken.tokenString
        return (idToken, accessToken)
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
