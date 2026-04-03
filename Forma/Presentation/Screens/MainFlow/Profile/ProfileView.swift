//
//  ProfileView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

// MARK: - Profile View

struct ProfileView: View {

    @StateObject private var viewModel: ProfileViewModel

    // Notification toggles — local state
    @State private var taskReminders: Bool  = true
    @State private var aiCheckIns: Bool     = true
    @State private var weeklyReview: Bool   = false

    // Coordinator callback — called on sign out
    var onSignOut: () -> Void
    var onEditProfile: () -> Void

    // MARK: - Init

    init(user: User,
         authRepository: AuthRepositoryProtocol,
         onSignOut: @escaping () -> Void,
         onEditProfile: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            user: user,
            authRepository: authRepository
        ))
        self.onSignOut    = onSignOut
        self.onEditProfile = onEditProfile
    }

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            AppColor.background.ignoresSafeArea()

            // Ambient glow
            RadialGradient(
                gradient: Gradient(colors: [
                    AppColor.gold.opacity(0.05),
                    .clear
                ]),
                center: .top,
                startRadius: 0,
                endRadius: 300
            )
            .frame(height: 400)
            .ignoresSafeArea()

            // Content
            ScrollView(showsIndicators: false) {
                VStack(spacing: AppSpacing.sectionGap) {

                    // ── Hero ──
                    ProfileHeroView(viewModel: viewModel)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    // ── Stats ──
                    ProfileStatsView(viewModel: viewModel)

                    // ── Forma AI Plan ──
                    ProfileAIPlanCard(onTap: {
                        // TODO: navigate to plan screen
                    })

                    // ── Preferences ──
                    preferencesSection

                    // ── Notifications ──
                    notificationsSection

                    // ── App ──
                    appSection

                    // ── Sign Out ──
                    signOutSection

                    // Version
                    Text("Forma · v1.0.0 · Built with intention")
                        .font(AppFont.ui(10, weight: .light))
                        .kerning(1)
                        .foregroundColor(AppColor.textMuted2)
                        .padding(.top, 4)
                        .padding(.bottom, 40)
                }
                .padding(.top, AppSpacing.tightGap)
            }
        }
        .confirmationDialog(
            "Sign out of Forma?",
            isPresented: $viewModel.showSignOutConfirm,
            titleVisibility: .visible
        ) {
            Button("Sign Out", role: .destructive) {
                viewModel.signOut { onSignOut() }
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Sign out failed", isPresented: .constant(viewModel.signOutError != nil)) {
            Button("OK") { viewModel.signOutError = nil }
        } message: {
            Text(viewModel.signOutError ?? "")
        }
        .overlay {
            if viewModel.isSigningOut {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                        .tint(AppColor.gold)
                        .scaleEffect(1.4)
                }
            }
        }
    }

    // MARK: - Preferences section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormaSectionHeader(title: "Preferences", actionLabel: "EDITABLE") {
                onEditProfile()
            }

            VStack(spacing: 8) {
                // Prayer Times Section
                HStack(spacing: 0) {
                    FormaSettingCard(
                        icon: "🕌",
                        iconTint: .accent,
                        title: "Prayer Times",
                        subtitle: viewModel.location,
                        trailing: .none
                    ) { }
                    
                    Text("Auto")
                        .font(AppFont.ui(10, weight: .semibold))
                        .foregroundColor(AppColor.accent)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(AppColor.accent.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .padding(.trailing, 16)
                }
                FormaDivider()

                // Wake Time Section
                FormaSettingCard(
                    icon: "🌅",
                    iconTint: .accent,
                    title: "Wake Time",
                    subtitle: "Weekdays \(viewModel.wakeUpFormatted)",
                    trailing: .none
                ) { }
                FormaDivider()

                // Sleep Time Section
                FormaSettingCard(
                    icon: "🌙",
                    iconTint: .neutral,
                    title: "Sleep Time",
                    subtitle: viewModel.sleepFormatted,
                    trailing: .none
                ) { }
                FormaDivider()

                // Work Style Section
                FormaSettingCard(
                    icon: "💼",
                    iconTint: .accent,
                    title: "Work Style",
                    subtitle: viewModel.workStyle ?? "Not set",
                    trailing: .none
                ) { }
                FormaDivider()

                    // Goals Section
                FormaSettingCard(
                    icon: "🎯",
                    iconTint: .neutral,
                    title: "Goals",
                    subtitle: viewModel.goalsFormatted,
                    trailing: .none
                ) { }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.surface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, AppSpacing.sectionGap)
    }

    // MARK: - Notifications section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormaSectionHeader(title: "Notifications")

            VStack(spacing: 0) {
                FormaSettingCard(
                    icon: "🔔",
                    iconTint: .neutral,
                    title: "Task Reminders",
                    subtitle: "5 min before each routine",
                    trailing: .toggle(isOn: $taskReminders, onToggle: { _ in })
                )
                FormaDivider()

                FormaSettingCard(
                    icon: "✦",
                    iconTint: .accent,
                    title: "AI Check-ins",
                    subtitle: "After skipped tasks",
                    trailing: .toggle(isOn: $aiCheckIns, onToggle: { _ in })
                )
                FormaDivider()

                FormaSettingCard(
                    icon: "📊",
                    iconTint: .neutral,
                    title: "Weekly Review",
                    subtitle: "Every Sunday, 20:00",
                    trailing: .toggle(isOn: $weeklyReview, onToggle: { _ in })
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.surface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, AppSpacing.sectionGap)
    }

    // MARK: - App section

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormaSectionHeader(title: "App")

            VStack(spacing: 0) {
                FormaSettingCard(
                    icon: "🎨",
                    iconTint: .accent,
                    title: "Appearance",
                    subtitle: "Dark · Always",
                    trailing: .none
                ) { }
                FormaDivider()

                FormaSettingCard(
                    icon: "🌍",
                    iconTint: .neutral,
                    title: "Language & Region",
                    subtitle: "English · \(viewModel.timezone)",
                    trailing: .none
                ) { }
                FormaDivider()

                FormaSettingCard(
                    icon: "🔒",
                    iconTint: .neutral,
                    title: "Privacy & Data",
                    subtitle: "Manage your data",
                    trailing: .none
                ) { }
                FormaDivider()

                FormaSettingCard(
                    icon: "⭐",
                    iconTint: .accent,
                    title: "Rate Forma",
                    subtitle: "App Store · Takes 10 seconds",
                    trailing: .none
                ) {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/idYOUR_APP_ID") {
                        UIApplication.shared.open(url)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(AppColor.surface1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(AppColor.border, lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, AppSpacing.sectionGap)
    }

    // MARK: - Sign out

    private var signOutSection: some View {
        Button {
            viewModel.showSignOutConfirm = true
        } label: {
            Text("Sign Out".uppercased())
                .font(AppFont.ui(12, weight: .medium))
                .kerning(1.2)
                .foregroundColor(AppColor.destructive)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColor.background)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.destructive.opacity(0.3), lineWidth: 1)
                )
        }
        .padding(.horizontal, AppSpacing.sectionGap)
        .disabled(viewModel.isSigningOut)
    }
}

// MARK: - Preview

#Preview {
    ProfileView(
        user: .mockUserData,
        authRepository: AuthRepository(),
        onSignOut: {},
        onEditProfile: {}
    )
}
