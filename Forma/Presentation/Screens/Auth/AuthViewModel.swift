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

@MainActor
final class AuthViewModel: NSObject, ObservableObject {

    // MARK: - Published Properties
    @Published var isAppleLoading: Bool = false
    @Published var isGoogleLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - User Data

    var userPreferences: UserPreferences?
    var routines: [RoutineBlock]?
    var hasUserData: Bool { userPreferences != nil }

    // MARK: - Private State

    private var currentNonce: String?
    private var appleSignInContinuation: CheckedContinuation<ASAuthorizationCredential, Error>?
    private var appleAuthController: ASAuthorizationController?

    // MARK: - Init

    init(userPreferences: UserPreferences? = nil, routines: [RoutineBlock]? = nil) {
        self.userPreferences = userPreferences
        self.routines = routines
    }

    // MARK: - Apple Sign In
    func requestAuthWithApple() async throws -> User? {
        if let userPreferences, let routines {
            return try await signUpWithApple(with: userPreferences, routines: routines)
        } else if let userCredentials = try await signInWithApple() {
            let user = User(credentials: userCredentials)
            return user
        }
        return nil
    }


    private func signInWithApple() async throws -> UserCredentials? {
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
        else { throw AuthError.invalidCredential }

        return  try await useCase.execute(with: .apple(token: idToken, nonce: nonce))
    }

    private func signUpWithApple(with userPreferences: UserPreferences, routines: [RoutineBlock]) async throws -> User? {
        isAppleLoading = true
        errorMessage = nil
        defer { isAppleLoading = false }

        let credential = try await requestAppleCredential()
        let useCase = DependencyContainer.shared.makeSignUpAuthUseCase()
        
        guard
            let appleCredential = credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleCredential.identityToken,
            let idToken = String(data: tokenData, encoding: .utf8),
            let nonce = currentNonce
        else { throw AuthError.invalidCredential }

        return try await useCase.execute(
            with: .apple(token: idToken, nonce: nonce),
            userPreferences: userPreferences,
            routines: routines
        )
    }

    // MARK: - Google Sign In

    func requestAuthWithGoogle() async throws -> User? {
        if let userPreferences, let routines {
            return try await signUpWithGoogle(with: userPreferences, routines: routines)
        } else if let userCredentials = try await signInWithGoogle() {
            let user = User(credentials: userCredentials)
            return user
        }
        return nil
    }

    private func signInWithGoogle() async throws -> UserCredentials? {
        isGoogleLoading = true
        errorMessage = nil
        defer { isGoogleLoading = false }
        
        let (idToken, accessToken) = try await requestGoogleTokens()
        let useCase = DependencyContainer.shared.makeSignInAuthUseCase()
        return try await useCase.execute(with: .google(idToken: idToken, accessToken: accessToken))
    }

    private func signUpWithGoogle(with userPreferences: UserPreferences, routines: [RoutineBlock]) async throws -> User? {
        isGoogleLoading = true
        errorMessage = nil
        defer { isGoogleLoading = false }
        
        let (idToken, accessToken) = try await requestGoogleTokens()
        let useCase = DependencyContainer.shared.makeSignUpAuthUseCase()
        return try await useCase.execute(
            with: .google(idToken: idToken, accessToken: accessToken),
            userPreferences: userPreferences,
            routines: routines
        )
    }
}

// MARK: - Apple Auth Internals

extension AuthViewModel {

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
        appleAuthController = controller   // retain to prevent mid-flight dealloc

        return try await withCheckedThrowingContinuation { continuation in
            self.appleSignInContinuation = continuation
            controller.performRequests()
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate
// Delegate callbacks arrive on the main thread — nonisolated + MainActor.assumeIsolated
// bridges them safely without a Task hop.

extension AuthViewModel: ASAuthorizationControllerDelegate {

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        MainActor.assumeIsolated {
            appleSignInContinuation?.resume(returning: authorization.credential)
            appleSignInContinuation = nil
            appleAuthController = nil
        }
    }

    nonisolated func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        MainActor.assumeIsolated {
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
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {

    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first { $0.activationState == .foregroundActive }
            return scene?.windows.first(where: \.isKeyWindow) ?? UIWindow()
        }
    }
}

// MARK: - Google Auth Internals

extension AuthViewModel {

    private func requestGoogleTokens() async throws -> (idToken: String, accessToken: String) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingGoogleClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let topVC = topViewController() else {
            throw AuthError.noPresentingViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.invalidCredential
        }

        return (idToken, result.user.accessToken.tokenString)
    }

    private func topViewController() -> UIViewController? {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        var vc = scene?.windows.first(where: \.isKeyWindow)?.rootViewController
        while let presented = vc?.presentedViewController { vc = presented }
        return vc
    }
}
