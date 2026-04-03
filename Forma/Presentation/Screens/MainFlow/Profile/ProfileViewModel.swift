//
//  ProfileViewModel.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import Foundation
import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - Published State

    @Published var isSigningOut: Bool = false
    @Published var signOutError: String? = nil
    @Published var showSignOutConfirm: Bool = false

    // MARK: - Dependencies

    let user: User
    private let authRepository: AuthRepositoryProtocol

    // MARK: - Init

    init(user: User, authRepository: AuthRepositoryProtocol) {
        self.user = user
        self.authRepository = authRepository
    }

    // MARK: - Computed: Credentials

    var displayName: String {
        let full = user.credentials.name
        let parts = full.split(separator: " ")
        guard parts.count >= 2 else { return full }
        return full // keep full name — we split in the view
    }

    var firstName: String {
        user.credentials.name.split(separator: " ").first.map(String.init) ?? user.credentials.name
    }

    var lastName: String {
        let parts = user.credentials.name.split(separator: " ")
        guard parts.count >= 2 else { return "" }
        return parts.dropFirst().joined(separator: " ")
    }

    var email: String { user.credentials.email }
    var isAnonymous: Bool { user.credentials.isAnonymous }

    // MARK: - Computed: Preferences

    var profession: String {
        user.preferences?.profession ?? "—"
    }

    var wakeUpFormatted: String {
        guard let prefs = user.preferences else { return "—" }
        return formatTime(prefs.wakeUpTime)
    }

    var sleepFormatted: String {
        guard let prefs = user.preferences else { return "—" }
        return formatTime(prefs.sleepTime)
    }

    var focusTimeFormatted: String {
        guard let focus = user.preferences?.focusTime else { return "—" }
        return formatTime(focus)
    }

    var goalsFormatted: String {
        user.preferences?.goal.joined(separator: " · ") ?? "—"
    }

    var prayerFrequency: String? {
        user.preferences?.prayerFrequency
    }

    var workStyle: String? {
        user.preferences?.workStyle
    }

    var timezone: String {
        user.preferences?.timezone ?? TimeZone.current.abbreviation() ?? "UTC"
    }

    var location: String {
        TimeZone.current.identifier
            .split(separator: "/")
            .last
            .map { String($0).replacingOccurrences(of: "_", with: " ") }
            ?? timezone
    }

    // MARK: - Actions

    func signOut(onComplete: @escaping () -> Void) {
        Task {
            isSigningOut = true
            do {
                try await authRepository.signOut()
                onComplete()
            } catch {
                signOutError = error.localizedDescription
                isSigningOut = false
            }
        }
    }

    // MARK: - Helpers

    private func formatTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        return f.string(from: date)
    }
}
