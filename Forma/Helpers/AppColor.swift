//
//  AppColor.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

// MARK: - Color Tokens
// All color definitions. Raw hex values live here only.
// Usage: AppColor.accentPrimary, AppColor.surface, etc.

enum AppColor {

    // MARK: - Accent
    static let accentPrimary   = Color(red: 0.55, green: 0.40, blue: 1.00)
    static let accentSecondary = Color(red: 0.30, green: 0.55, blue: 1.00)

    /// Accent gradient — used on logo container, editorial rule
    static let accentGradient = LinearGradient(
        colors: [accentPrimary, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Fading accent rule — editorial line in auth / detail views
    static let accentFadeGradient = LinearGradient(
        colors: [accentPrimary.opacity(AppOpacity.accentRuleLead),
                 accentPrimary.opacity(0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Base
    static let background = Color.backgroundPrimary
    static let white      = Color.white

    // MARK: - Surface (glass panels)
    static let surfaceFill        = Color.white.opacity(AppOpacity.surfaceFill)
    static let surfaceFillStrong  = Color.white.opacity(AppOpacity.surfaceFillStrong)
    static let surfaceBorder      = Color.white.opacity(AppOpacity.surfaceBorder)
    static let surfaceDivider     = Color.white.opacity(AppOpacity.surfaceDivider)

    // MARK: - Text hierarchy
    static let textPrimary    = Color.white.opacity(AppOpacity.textPrimary)
    static let textSecondary  = Color.white.opacity(AppOpacity.textSecondary)
    static let textTertiary   = Color.white.opacity(AppOpacity.textTertiary)
    static let textDisabled   = Color.white.opacity(AppOpacity.textDisabled)
    static let textWordmark   = Color.white.opacity(AppOpacity.textWordmark)

    // MARK: - Error
    static let errorFill      = Color(red: 1.0, green: 0.2,  blue: 0.3)
    static let errorText      = Color(red: 1.0, green: 0.45, blue: 0.45)
    static let errorBorder    = errorFill.opacity(0.25)
    static let errorBackground = errorFill.opacity(0.10)

    // MARK: - Glow
    /// Bottom radial glow on auth screen
    static let glowBottom = RadialGradient(
        colors: [accentPrimary.opacity(0.11), .clear],
        center: .init(x: 0.5, y: 1.15),
        startRadius: 0,
        endRadius: 420
    )

    /// Logo shadow glow
    static let logoGlow = accentPrimary.opacity(0.5)
}

// MARK: - Opacity Tokens
// Single source of truth for all opacity values.
// Usage: .opacity(AppOpacity.textPrimary)

enum AppOpacity {

    // MARK: - Text
    static let textPrimary:   Double = 0.92
    static let textSecondary: Double = 0.55
    static let textTertiary:  Double = 0.28
    static let textDisabled:  Double = 0.20
    static let textWordmark:  Double = 0.30
    static let textMicro:     Double = 0.18   // footer, section labels
    static let textHint:      Double = 0.15   // placeholder text

    // MARK: - Surface
    static let surfaceFill:       Double = 0.035
    static let surfaceFillStrong: Double = 0.055
    static let surfaceBorder:     Double = 0.08
    static let surfaceDivider:    Double = 0.06

    // MARK: - Accent
    static let accentRuleLead: Double = 0.9   // leading edge of editorial rule
    static let accentIcon:     Double = 0.6
    static let accentSubtle:   Double = 0.1   // button background tint

    // MARK: - Interactive
    static let pressedScale:   Double = 0.82  // button opacity on press
    static let disabledText:   Double = 0.20
    static let loadingSpinner: Double = 0.45

    // MARK: - Grain
    static let grainDensity:   Double = 0.14  // fraction of pixels covered
    static let grainAlphaMin:  Double = 0.008
    static let grainAlphaMax:  Double = 0.063

    // MARK: - Row / Panel
    static let dragHandle:     Double = 0.12
    static let rowDivider:     Double = 0.055
    static let shimmer:        Double = 0.07
    static let statusDotCore:  Double = 0.55
    static let statusDotRing:  Double = 0.15
}
