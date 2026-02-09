//
//  AuthRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/8/26.
//

import Foundation

enum AuthProvider {
    case google(idToken: String, accessToken: String)
    case apple(token: String, nonce: String)
    case anonymous
}

protocol AuthRepositoryProtocol {
    func signIn(with authProvider: AuthProvider) async throws -> UserCredentials?
    func signUp(with authProvider: AuthProvider) async throws -> UserCredentials?
    func signOut() throws
    func deleteUser() throws
}
