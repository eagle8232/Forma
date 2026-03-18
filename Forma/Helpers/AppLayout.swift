//
//  AppLayout.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import SwiftUI

// MARK: - Corner Radius Tokens
// Usage: .cornerRadius(AppRadius.card) or .clipShape(RoundedRectangle(cornerRadius: AppRadius.button))

enum AppRadius {

    // MARK: - Containers
    static let card:    CGFloat = 20    // task list panel, routine panel
    static let cardLg:  CGFloat = 24    // auth bottom block
    static let panel:   CGFloat = 18    // generation routine table

    // MARK: - Buttons
    static let button:      CGFloat = 26   // pill — Create Account, full-width CTAs
    static let buttonSm:    CGFloat = 16   // Add task button
    static let capsule:     CGFloat = 999  // true capsule (use Capsule() shape instead)

    // MARK: - Elements
    static let logo:        CGFloat = 22   // app icon container
    static let toast:       CGFloat = 14   // error toast
    static let stepperInner: CGFloat = 8   // duration pill inside stepper
    static let tag:         CGFloat = 6    // small pills / badges
    static let dot:         CGFloat = 999  // status dot (use Circle() instead)
}

// MARK: - Spacing Tokens
// Consistent spacing scale used for padding, gaps, and margins.
// Usage: .padding(.horizontal, AppSpacing.screenH)

enum AppSpacing {

    // MARK: - Screen margins
    static let screenH: CGFloat = 28    // horizontal screen edge padding
    static let screenHWide: CGFloat = 32
    static let screenBottom: CGFloat = 52
    static let screenTop: CGFloat = 56  // below status bar

    // MARK: - Section gaps
    static let sectionGap: CGFloat = 20
    static let blockGap:   CGFloat = 16
    static let itemGap:    CGFloat = 12
    static let tightGap:   CGFloat = 8
    static let microGap:   CGFloat = 4

    // MARK: - Row internal
    static let rowV:       CGFloat = 18   // row vertical padding
    static let rowLeading: CGFloat = 8
    static let rowTrailing: CGFloat = 20

    // MARK: - Panel internal
    static let panelH:     CGFloat = 24
    static let panelV:     CGFloat = 20

    // MARK: - Button
    static let buttonH:    CGFloat = 32   // horizontal padding inside buttons
    static let buttonHeight: CGFloat = 54
    static let buttonHeightLg: CGFloat = 60

    // MARK: - Stepper
    static let stepperH:   CGFloat = 20
    static let stepperV:   CGFloat = 18

    // MARK: - Divider
    static let dividerLeadingInset: CGFloat = 68   // hairline indent in routine list
}

// MARK: - Animation Tokens
// Reusable animation presets for consistent motion across the app.
// Usage: .animation(AppAnimation.spring, value: someState)

enum AppAnimation {

    // MARK: - Springs
    static let spring = Animation.spring(response: 0.42, dampingFraction: 0.82)
    static let springFast = Animation.spring(response: 0.28, dampingFraction: 0.75)
    static let springGentle = Animation.spring(response: 0.55, dampingFraction: 0.82)
    static let springBouncy = Animation.spring(response: 0.45, dampingFraction: 0.75)

    // MARK: - Ease
    static let easeIn  = Animation.easeInOut(duration: 0.2)
    static let easeStd = Animation.easeOut(duration: 0.4)
    static let easeSlow = Animation.easeOut(duration: 0.6)

    // MARK: - Appear stagger delays
    static let appearDelay0: Double = 0.05
    static let appearDelay1: Double = 0.14
    static let appearDelay2: Double = 0.24

    // MARK: - Press feedback
    static let press = Animation.easeInOut(duration: 0.1)

    // MARK: - Content transitions
    static let fadeSwap = Animation.easeInOut(duration: 0.4)

    // MARK: - Scale values
    static let pressedScale: CGFloat = 0.985
    static let appearFromScale: CGFloat = 0.97
}

// MARK: - Size Tokens
// Fixed dimensions for icons, logos, indicators.

enum AppSize {

    // MARK: - Logo
    static let logoContainer: CGFloat = 72
    static let logoIcon:      CGFloat = 32

    // MARK: - Status dot
    static let dotCore:  CGFloat = 4
    static let dotRing:  CGFloat = 10

    // MARK: - Icons
    static let iconSm:   CGFloat = 11
    static let iconMd:   CGFloat = 14
    static let iconLg:   CGFloat = 16
    static let iconXLg:  CGFloat = 18

    // MARK: - Dividers
    static let hairline: CGFloat = 0.5

    // MARK: - Breathing / shimmer
    static let breathingLineW: CGFloat = 24
    static let breathingLineH: CGFloat = 1
    static let completionMarkW: CGFloat = 20

    // MARK: - Stepper circle button
    static let stepperButton: CGFloat = 44

    // MARK: - Duration arc bar
    static let durationArcH: CGFloat = 3
}
