//
//  SignUpViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import SwiftUI

struct AuthView: View {
    @StateObject private var vm: AuthViewModel
    var onSuccess: (User) -> Void
    var onDismiss: (() -> Void)?

    init(
        userPreferences: UserPreferences? = nil,
        routines: [RoutineBlock]? = nil,
        onSuccess: @escaping ((User) -> Void),
        onDismiss: (() -> Void)? = nil
    ) {
        _vm = StateObject(wrappedValue: AuthViewModel(
            userPreferences: userPreferences,
            routines: routines
        ))
        self.onSuccess = onSuccess
        self.onDismiss = onDismiss
    }

    @State private var appeared = false

    var body: some View {
        ZStack {
            AppColor.background.ignoresSafeArea()

            GrainOverlay()
                .ignoresSafeArea()
                .allowsHitTesting(false)

            AppColor.glowBottom
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                topBar
                    .padding(.top, 12)
                    .padding(.horizontal, AppSpacing.screenH)
                    .opacity(appeared ? 1 : 0)
                    .animation(.easeOut(duration: 0.45).delay(AppAnimation.appearDelay0), value: appeared)

                Spacer()

                headlineBlock
                    .padding(.horizontal, AppSpacing.screenHWide)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 22)
                    .animation(.easeOut(duration: 0.6).delay(AppAnimation.appearDelay1), value: appeared)

                Spacer()

                bottomBlock
                    .padding(.horizontal, AppSpacing.screenH)
                    .padding(.bottom, AppSpacing.screenBottom)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 28)
                    .animation(.easeOut(duration: 0.55).delay(AppAnimation.appearDelay2), value: appeared)
            }

            if let error = vm.errorMessage {
                errorToast(message: error)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .zIndex(10)
            }
        }
        .animation(AppAnimation.easeIn, value: vm.errorMessage != nil)
        .onAppear { withAnimation { appeared = true } }
    }
}

// MARK: - Top Bar

extension AuthView {

    private var topBar: some View {
        HStack {
            Text("FORMA")
                .customFont(.wordmark)
                .tracking(AppTracking.wordmark)
                .foregroundStyle(AppColor.textWordmark)
            Spacer()
        }
    }
}

// MARK: - Headline

extension AuthView {

    private var headlineBlock: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Editorial rule
            HStack(spacing: 0) {
                Rectangle()
                    .fill(AppColor.accentFadeGradient)
                    .frame(width: 88, height: AppSize.hairline)
                Rectangle()
                    .fill(AppColor.surfaceDivider)
                    .frame(height: AppSize.hairline)
            }
            .padding(.bottom, 30)

            Text("let's go")
                .customFont(.displayThin)
                .tracking(AppTracking.display)
                .foregroundStyle(AppColor.textPrimary)

            Text("Build your perfect\nday, once.")
                .customFont(.ultraLight)
                .tracking(AppTracking.bodyTight)
                .foregroundStyle(AppColor.textTertiary)
                .lineSpacing(6)
                .padding(.top, AppSpacing.blockGap)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Bottom Block

extension AuthView {

    private var bottomBlock: some View {
        VStack(spacing: 0) {
            appleButton

            Rectangle()
                .fill(AppColor.surfaceDivider)
                .frame(height: AppSize.hairline)
                .padding(.horizontal, 1)

            googleButton

            Text("By continuing you agree to our **Terms of Use** and **Privacy Policy**")
                .customFont(.microTracked)
                .tracking(AppTracking.caption)
                .foregroundStyle(AppColor.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.panelH)
                .padding(.top, AppSpacing.panelV + 4)
                .padding(.bottom, AppSpacing.panelV)
        }
        .background(
            RoundedRectangle(cornerRadius: AppRadius.cardLg)
                .fill(AppColor.surfaceFill)
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.cardLg)
                        .stroke(AppColor.surfaceBorder, lineWidth: AppSize.hairline)
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.cardLg))
    }

    private var appleButton: some View {
        Button {
            Task {
                do {
                    guard let user = try await vm.requestAuthWithApple() else {
                        throw AuthError.missingUserData
                    }
                    onSuccess(user)
                } catch let e as AuthError where e == .cancelled { }
                  catch let e as AuthError { vm.errorMessage = e.errorDescription }
                  catch { vm.errorMessage = "Apple Sign In failed. Please try again." }
            }
        } label: {
            HStack(spacing: AppSpacing.tightGap + 2) {
                if vm.isAppleLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.black.opacity(0.5))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "apple.logo")
                        .font(.system(size: AppSize.iconLg, weight: .medium))
                        .foregroundStyle(AppColor.background)
                    Text("Continue with Apple")
                        .customFont(.buttonMedium)
                        .foregroundStyle(AppColor.background)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSpacing.buttonHeightLg)
            .background(AppColor.white)
            .clipShape(
                .rect(
                    topLeadingRadius: AppRadius.cardLg,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: AppRadius.cardLg
                )
            )
        }
        .buttonStyle(AuthButtonStyle())
        .disabled(vm.isAppleLoading)
    }

    private var googleButton: some View {
        Button {
            Task {
                do {
                    guard let user = try await vm.requestAuthWithGoogle() else {
                        throw AuthError.missingUserData
                    }
                    onSuccess(user)
                } catch let e as AuthError where e == .cancelled { }
                  catch let e as AuthError { vm.errorMessage = e.errorDescription }
                  catch { vm.errorMessage = "Google Sign In failed. Please try again." }
            }
        } label: {
            HStack(spacing: AppSpacing.tightGap + 2) {
                if vm.isGoogleLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(AppColor.white.opacity(AppOpacity.loadingSpinner))
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "g.circle.fill")
                        .font(.system(size: AppSize.iconXLg, weight: .ultraLight))
                        .foregroundStyle(AppColor.white.opacity(0.5))
                    Text("Continue with Google")
                        .customFont(.ultraLight)
                        .tracking(AppTracking.bodyTight)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: AppSpacing.buttonHeightLg)
        }
        .buttonStyle(AuthButtonStyle())
        .disabled(vm.isGoogleLoading)
    }
}

// MARK: - Button Style

private struct AuthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? AppAnimation.pressedScale : 1.0)
            .opacity(configuration.isPressed ? AppOpacity.pressedScale : 1.0)
            .animation(AppAnimation.press, value: configuration.isPressed)
    }
}

// MARK: - Error Toast

extension AuthView {

    @ViewBuilder
    private func errorToast(message: String) -> some View {
        VStack {
            HStack(spacing: AppSpacing.tightGap + 2) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: AppSize.iconSm, weight: .light))
                    .foregroundStyle(AppColor.errorText.opacity(0.8))

                Text(message)
                    .customFont(.caption)
                    .foregroundStyle(AppColor.errorText)
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, AppSpacing.blockGap)
            .padding(.vertical, AppSpacing.itemGap)
            .background(
                RoundedRectangle(cornerRadius: AppRadius.toast)
                    .fill(AppColor.errorBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.toast)
                            .stroke(AppColor.errorBorder, lineWidth: AppSize.hairline)
                    )
            )
            .padding(.horizontal, AppSpacing.screenHWide)
            .padding(.top, 60)

            Spacer()
        }
        .task {
            try? await Task.sleep(for: .seconds(4))
            withAnimation(.easeOut(duration: 0.3)) { vm.errorMessage = nil }
        }
    }
}
