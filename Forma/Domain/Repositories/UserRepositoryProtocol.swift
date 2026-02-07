//
//  UserRepositoryProtocol.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/7/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUser() async throws -> User
    func saveUser(_ user: User) async throws
    func deleteUser(_ user: User) async throws
}
