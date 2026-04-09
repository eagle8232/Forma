//
//  ProfileView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 4/2/26.
//

import SwiftUI

struct ProfileView: View {

    @StateObject private var viewModel: ProfileViewModel

    @State private var taskReminders: Bool  = NotificationManager.shared.isTaskRemindersEnabled
    @State private var aiCheckIns: Bool     = NotificationManager.shared.isAICheckInsEnabled
    @State private var weeklyReview: Bool   = NotificationManager.shared.isWeeklyReviewEnabled
    @State private var showStatsSheet: Bool = false
    @State private var showAppearancePicker: Bool = false
    @State private var showRegionPicker: Bool = false
    @State private var selectedAppearance: AppearanceMode = .system

    var coordinator: HomeCoordinator?
    var onSignOut: () -> Void
    var onEditProfile: () -> Void

    // MARK: - Init

    init(user: User,
         authRepository: AuthRepositoryProtocol,
         coordinator: HomeCoordinator? = nil,
         onSignOut: @escaping () -> Void,
         onEditProfile: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ProfileViewModel(
            user: user,
            authRepository: authRepository
        ))
        self.coordinator = coordinator
        self.onSignOut    = onSignOut
        self.onEditProfile = onEditProfile
        self._selectedAppearance = State(initialValue: user.preferences?.resolvedAppearanceMode ?? .system)
    }
    
    private func applyAppearance(_ mode: AppearanceMode) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        
        switch mode {
        case .system:
            window.overrideUserInterfaceStyle = .unspecified
        case .dark:
            window.overrideUserInterfaceStyle = .dark
        case .light:
            window.overrideUserInterfaceStyle = .light
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ProfileHeroView(viewModel: viewModel)
                    ProfileStatsView(viewModel: viewModel)
                    preferencesSection
                    notificationsSection
                    appSection
                    signOutSection
                }
                .padding(.top, 8)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            viewModel.loadStats()
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
        .confirmationDialog(
            "Delete your account?",
            isPresented: $viewModel.showDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                viewModel.deleteAccount { onSignOut() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all your data including routines, preferences, and statistics. This action cannot be undone.")
        }
        .alert("Delete failed", isPresented: .constant(viewModel.deleteError != nil)) {
            Button("OK") { viewModel.deleteError = nil }
        } message: {
            Text(viewModel.deleteError ?? "")
        }
        .overlay {
            if viewModel.isSigningOut || viewModel.isDeleting {
                ZStack {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                        .tint(AppColor.accent)
                        .scaleEffect(1.4)
                }
            }
        }
        .sheet(isPresented: $showStatsSheet) {
            StatsView()
        }
        .sheet(isPresented: $viewModel.showWakeTimePicker) {
            TimePickerSheet(
                title: "Wake Time",
                selectedTime: Binding(
                    get: { viewModel.editingWakeTime },
                    set: { viewModel.editingWakeTime = $0 }
                ),
                onSave: {
                    viewModel.updateWakeTime(viewModel.editingWakeTime)
                    viewModel.showWakeTimePicker = false
                },
                onCancel: {
                    viewModel.showWakeTimePicker = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showSleepTimePicker) {
            TimePickerSheet(
                title: "Sleep Time",
                selectedTime: Binding(
                    get: { viewModel.editingSleepTime },
                    set: { viewModel.editingSleepTime = $0 }
                ),
                onSave: {
                    viewModel.updateSleepTime(viewModel.editingSleepTime)
                    viewModel.showSleepTimePicker = false
                },
                onCancel: {
                    viewModel.showSleepTimePicker = false
                }
            )
        }
        .sheet(isPresented: $viewModel.showWorkStylePicker) {
            WorkStylePickerSheet(
                selectedStyle: viewModel.workStyle,
                onSelect: { style in
                    viewModel.updateWorkStyle(style)
                    viewModel.showWorkStylePicker = false
                },
                onCancel: {
                    viewModel.showWorkStylePicker = false
                }
            )
        }
        .sheet(isPresented: $showAppearancePicker) {
            AppearancePickerSheet(
                selectedMode: $selectedAppearance,
                onSelect: { mode in
                    viewModel.updateAppearanceMode(mode)
                    applyAppearance(mode)
                    showAppearancePicker = false
                },
                onDismiss: { showAppearancePicker = false }
            )
        }
        .sheet(isPresented: $showRegionPicker) {
            RegionPickerSheet(
                onDismiss: { showRegionPicker = false }
            )
        }
    }

    // MARK: - Preferences section

    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormaSectionHeader(title: "Preferences")

            VStack(spacing: 8) {
                // Sleep Schedule Card
                SleepScheduleCard(
                    wakeTime: viewModel.user.preferences?.wakeUpTime ?? Date(),
                    sleepTime: viewModel.user.preferences?.sleepTime ?? Date(),
                    onWakeTap: {
                        coordinator?.showSleepScheduleEdit(user: viewModel.user)
                    },
                    onSleepTap: {
                        coordinator?.showSleepScheduleEdit(user: viewModel.user)
                    }
                )
                
                // Work Style Section
                FormaSettingCard(
                    icon: "💼",
                    iconTint: .accent,
                    title: "Work Style",
                    subtitle: viewModel.workStyle ?? "Not set",
                    trailing: .none
                )
                FormaDivider()

                    // Goals Section
                FormaSettingCard(
                    icon: "🎯",
                    iconTint: .neutral,
                    title: "Goals",
                    subtitle: viewModel.goalsFormatted,
                    trailing: .none
                )
                
                if let additionalContext = viewModel.additionalContextFormatted {
                    FormaDivider()
                    
                    // Additional AI Preferences
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text("✨")
                                .font(.system(size: 14))
                            Text("AI Preferences")
                                .font(AppFont.ui(12, weight: .medium))
                                .foregroundColor(AppColor.textMuted)
                        }
                        
                        Text(additionalContext)
                            .font(AppFont.ui(11, weight: .regular))
                            .foregroundColor(AppColor.textSecondary)
                            .lineLimit(3)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
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

    // MARK: - Notifications section

    private var notificationsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormaSectionHeader(title: "Premium Features")

            VStack(spacing: 0) {
                FormaSettingCard(
                    icon: "🔔",
                    iconTint: .neutral,
                    title: "Task Reminders",
                    subtitle: "5 min before each routine",
                    trailing: .toggle(isOn: $taskReminders, onToggle: { isOn in
                        NotificationManager.shared.isTaskRemindersEnabled = isOn
                        if isOn {
                            scheduleNotifications()
                        } else {
                            NotificationManager.shared.cancelAllNotifications()
                        }
                    })
                )
                FormaDivider()

                FormaSettingCard(
                    icon: "✦",
                    iconTint: .accent,
                    title: "AI Check-ins",
                    subtitle: "After skipped tasks",
                    trailing: .toggle(isOn: $aiCheckIns, onToggle: { isOn in
                        NotificationManager.shared.isAICheckInsEnabled = isOn
                    })
                )
                FormaDivider()

                FormaSettingCard(
                    icon: "📊",
                    iconTint: .neutral,
                    title: "Weekly Review",
                    subtitle: "Every Sunday, 20:00",
                    trailing: .toggle(isOn: $weeklyReview, onToggle: { isOn in
                        NotificationManager.shared.isWeeklyReviewEnabled = isOn
                        if isOn {
                            NotificationManager.shared.scheduleWeeklyReview()
                        } else {
                            NotificationManager.shared.cancelWeeklyReview()
                        }
                    })
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
    
    private func scheduleNotifications() {
        guard let routines = DependencyContainer.shared.routines else { return }
        for routine in routines {
            NotificationManager.shared.scheduleRoutineReminder(routine: routine)
            NotificationManager.shared.scheduleRoutineStartNotification(routine: routine)
        }
        if weeklyReview {
            NotificationManager.shared.scheduleWeeklyReview()
        }
    }

    // MARK: - App section

    private var appSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            FormaSectionHeader(title: "App")

            VStack(spacing: 0) {
                FormaSettingCard(
                    icon: "📊",
                    iconTint: .accent,
                    title: "Statistics",
                    subtitle: "View your progress and streaks",
                    trailing: .chevron
                ) {
                    showStatsSheet = true
                }
                FormaDivider()
                
                FormaSettingCard(
                    icon: "🎨",
                    iconTint: .accent,
                    title: "Appearance",
                    subtitle: appearanceSubtitle,
                    trailing: .chevron
                ) {
                    showAppearancePicker = true
                }
                FormaDivider()

                FormaSettingCard(
                    icon: "🌍",
                    iconTint: .neutral,
                    title: "Region",
                    subtitle: selectedRegion,
                    trailing: .chevron
                ) {
                    showRegionPicker = true
                }
                FormaDivider()

                FormaSettingCard(
                    icon: "🔒",
                    iconTint: .neutral,
                    title: "Terms of Use & Privacy Policy",
                    subtitle: "Read our policies",
                    trailing: .chevron
                ) {
                    if let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                        UIApplication.shared.open(url)
                    }
                }
                FormaDivider()

                FormaSettingCard(
                    icon: "⭐",
                    iconTint: .accent,
                    title: "Rate Forma",
                    subtitle: "App Store · Takes 10 seconds",
                    trailing: .chevron
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
    
    private var appearanceSubtitle: String {
        switch selectedAppearance {
        case .system: return "System"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
    
    private var selectedRegion: String {
        let tz = TimeZone.current
        let parts = tz.identifier.split(separator: "/")
        return parts.last?.replacingOccurrences(of: "_", with: " ").capitalized ?? tz.abbreviation() ?? "UTC"
    }

    // MARK: - Account section

    private var signOutSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.showSignOutConfirm = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(viewModel.email)
                            .font(AppFont.ui(14, weight: .medium))
                            .foregroundColor(AppColor.destructive)
                        
                        Text("Sign out")
                            .font(AppFont.ui(10, weight: .regular))
                            .foregroundColor(AppColor.destructive.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(AppColor.destructive.opacity(0.5))
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(AppColor.background)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.md)
                        .stroke(AppColor.destructive.opacity(0.3), lineWidth: 1)
                )
            }
            .disabled(viewModel.isSigningOut)
            
            Button {
                viewModel.showDeleteConfirm = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "trash")
                        .font(.system(size: 12, weight: .medium))
                    Text("Delete Account".uppercased())
                        .font(AppFont.ui(12, weight: .medium))
                }
                .kerning(1.2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColor.destructive)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
            }
            .disabled(viewModel.isDeleting || viewModel.isSigningOut)
        }
        .padding(.horizontal, AppSpacing.sectionGap)
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
