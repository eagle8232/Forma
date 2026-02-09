//
//  FirebaseAuthRepositoru.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

final class AuthRepository: AuthRepositoryProtocol {
    
    // - Sign In
    
    func signIn(with authProvider: AuthProvider) async throws -> UserCredentials? {
                
        guard let result = try await authProviderSetup(with: authProvider) else {
            print("Could not create Firebase credentials")
            return nil
        }
        
        let userCredentials = UserCredentials(
            id: result.user.uid,
            name: result.user.displayName ?? "Unknown name",
            email: result.user.email ?? "Unknown name"
        )
        
        return userCredentials
    }
    
    // - Sign Up
    
    func signUp(with authProvider: AuthProvider) async throws -> UserCredentials? {
        
        guard let result = try await authProviderSetup(with: authProvider) else {
            print("Could not create Firebase credentials")
            return nil
        }
        
        let userCredentials = UserCredentials(
            id: result.user.uid,
            name: result.user.displayName ?? "Unknown name",
            email: result.user.email ?? "Unknown name"
        )
        
        return userCredentials
    }
    
    // - Sign Out
    
    func signOut() async throws {
        try Auth.auth().signOut()
    }
    
    // - Delete User
    
    func deleteUser() async throws {
        guard let currentUser = Auth.auth().currentUser else {return}
        try await currentUser.delete()
    }
    
    // - MARK: Fileprivate functions
    
    fileprivate func authProviderSetup(with authProvider: AuthProvider) async throws -> AuthDataResult? {
        
        switch authProvider {
        case .google(let token, let accessToken):
            
            let credential = GoogleAuthProvider.credential(withIDToken: token,
                                                           accessToken: accessToken)
            return try await Auth.auth().signIn(with: credential)
            
        case .apple(let token, _):
            
            let credential = OAuthProvider.credential(providerID: .apple, idToken: token)
            return try await Auth.auth().signIn(with: credential)
            
        case .anonymous:
            return try await Auth.auth().signInAnonymously()
        }
    }
    
    fileprivate func mapAuthError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        // Map specific Firebase error codes here
        if nsError.code == 17008 { return .invalidEmail }
        // ... other codes
        return .unknown
    }
    
}
