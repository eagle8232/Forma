//
//  AuthError.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/9/26.
//

import Foundation

enum AuthError: LocalizedError {
    case cancelled
    case invalidCredential
    case missingUserData
    case missingGoogleClientID
    case noPresentingViewController
    case requiresReauthentication

    var errorDescription: String? {
        switch self {
        case .cancelled:             return nil // Silent — user chose to cancel
        case .invalidCredential:     return "We couldn't verify your credentials. Please try again."
        case .missingUserData:       return "Your profile data is missing. Please restart the setup."
        case .missingGoogleClientID: return "Google Sign-In is not configured correctly."
        case .noPresentingViewController: return "Unable to present the sign-in screen."
        case .requiresReauthentication: return "Please sign in again to delete your account."
        }
    }
}
