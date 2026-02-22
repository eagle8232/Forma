//
//  AuthViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import Foundation
import Combine
import AuthenticationServices
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

final class AuthViewModel: NSObject {

    // MARK: - Published Properties

    @Published var isAppleLoading: Bool = false
    @Published var isGoogleLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - User Data (for sign-up flow)

    var userPreferences: UserPreferences?
    var routines: [RoutineBlock]?

    var hasUserData: Bool { userPreferences != nil }

    // MARK: - Private State

    private var currentNonce: String?

    // Continuation bridges for Apple's delegate-based flow → async/await
    private var appleSignInContinuation: CheckedContinuation<ASAuthorizationCredential, Error>?

    private var appleAuthController: ASAuthorizationController?
    
    // MARK: - Apple Sign In

    func signInWithApple() async throws {
        isAppleLoading = true
        errorMessage = nil
        defer { isAppleLoading = false }

        let credential = try await requestAppleCredential()
        let useCase = DependencyContainer.shared.makeSignInAuthUseCase()

        guard
            let appleCredential = credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else {
            throw AuthError.invalidCredential
        }

        _ = try await useCase.execute(with: .apple(token: idToken, nonce: nonce))
    }

    func signUpWithApple() async throws {
        isAppleLoading = true
        errorMessage = nil
        defer { isAppleLoading = false }

        guard let userPreferences, let routines else {
            throw AuthError.missingUserData
        }

        let credential = try await requestAppleCredential()
        let useCase = DependencyContainer.shared.makeSignUpAuthUseCase()

        guard
            let appleCredential = credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else {
            throw AuthError.invalidCredential
        }

        _ = try await useCase.execute(
            with: .apple(token: idToken, nonce: nonce),
            userPreferences: userPreferences,
            routines: routines
        )
    }

    // MARK: - Google Sign In
    
    func requestAuthWithGoogle() async throws {
        if let userPreferences, let routines {
            try await signUpWithGoogle(with: userPreferences, routines: routines)
        } else {
            try await signInWithGoogle()
        }
        
    }

    func signInWithGoogle() async throws {
        isGoogleLoading = true
        errorMessage = nil
        defer { isGoogleLoading = false }

        let (idToken, accessToken) = try await requestGoogleTokens()
        let useCase = DependencyContainer.shared.makeSignInAuthUseCase()
        let _ = try await useCase.execute(with: .google(idToken: idToken, accessToken: accessToken))
    }

    func signUpWithGoogle(with userPreferences: UserPreferences, routines: [RoutineBlock]) async throws {
        isGoogleLoading = true
        errorMessage = nil
        defer { isGoogleLoading = false }

        let (idToken, accessToken) = try await requestGoogleTokens()
        let useCase = DependencyContainer.shared.makeSignUpAuthUseCase()

        _ = try await useCase.execute(
            with: .google(idToken: idToken, accessToken: accessToken),
            userPreferences: userPreferences,
            routines: routines
        )
    }
}

// MARK: - Apple Auth Internals

extension AuthViewModel {

    /// Presents the Apple ID authorization sheet and bridges the delegate callbacks into async/await.
    private func requestAppleCredential() async throws -> ASAuthorizationCredential {
            let nonce = CryptoUtils.randomNonceString()
            currentNonce = nonce

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = CryptoUtils.sha256(nonce)

            let controller = ASAuthorizationController(authorizationRequests: [request])
            controller.delegate = self
            controller.presentationContextProvider = self

            // Retain the controller — without this it deallocates mid-flight
            // and the delegate never fires, causing a silent failure.
            appleAuthController = controller

            return try await withCheckedThrowingContinuation { continuation in
                self.appleSignInContinuation = continuation
                controller.performRequests()
            }
        }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthViewModel: ASAuthorizationControllerDelegate {

    func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithAuthorization authorization: ASAuthorization
        ) {
            appleSignInContinuation?.resume(returning: authorization.credential)
            appleSignInContinuation = nil
            appleAuthController = nil
        }

        func authorizationController(
            controller: ASAuthorizationController,
            didCompleteWithError error: Error
        ) {
            if let authError = error as? ASAuthorizationError,
               authError.code == .canceled {
                appleSignInContinuation?.resume(throwing: AuthError.cancelled)
            } else {
                appleSignInContinuation?.resume(throwing: error)
            }
            appleSignInContinuation = nil
            appleAuthController = nil
        }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        // Walk the scene hierarchy to find a key window
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        return scene?.windows.first(where: \.isKeyWindow) ?? UIWindow()
    }
}

// MARK: - Google Auth Internals

extension AuthViewModel {

    @MainActor
    /// Presents Google Sign-In sheet and bridges the callback into async/await.
    private func requestGoogleTokens() async throws -> (idToken: String, accessToken: String) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingGoogleClientID
        }
        print(clientID)
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let topVC = topViewController() else {
            throw AuthError.noPresentingViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        print(result)
        guard
            let idToken = result.user.idToken?.tokenString
        else {
            throw AuthError.invalidCredential
        }

        let accessToken = result.user.accessToken.tokenString
        print(accessToken)
        return (idToken, accessToken)
    }
    
    @MainActor
    private func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var vc = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
        while let presented = vc?.presentedViewController { vc = presented }
        return vc
    }
}
