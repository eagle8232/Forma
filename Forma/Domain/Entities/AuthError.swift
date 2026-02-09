//
//  AuthError.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/9/26.
//

import Foundation

enum AuthError: Error, LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case userNotFound
    case wrongPassword
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "The email format is incorrect."
        case .weakPassword:
            return "Your password must be at least 6 characters."
        case .emailAlreadyInUse:
            return "This email is already registered."
        case .userNotFound:
            return "No account found with these credentials."
        case .wrongPassword:
            return "The password you entered is incorrect."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
}
