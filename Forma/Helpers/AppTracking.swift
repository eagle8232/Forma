//
//  AppTracking.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/18/26.
//

import CoreGraphics

// MARK: - Tracking Tokens
// All letter-spacing values used across the app.
// Use alongside Typography's customFont() modifier when you need
// to override tracking beyond what the Typography system provides.
//
// Usage: .tracking(AppTracking.wordmark)
//
// Note: For standard Typography cases, tracking is already baked
// into customFont() via Typography.tracking. Use AppTracking directly
// only for one-off overrides or non-Typography contexts.

enum AppTracking {

    // MARK: - Brand
    static let wordmark:      CGFloat = 6.0   // "FORMA"

    // MARK: - Display
    static let display:       CGFloat = -2.0  // large thin headlines
    static let displayMedium: CGFloat = -0.5  // standard display (matches Typography)

    // MARK: - Labels / Caps
    static let sectionLabel:  CGFloat = 4.0   // "ACTIVITIES", "ROUTINES", "DURATION"
    static let microLabel:    CGFloat = 3.0   // "THINKING", "COMPLETE", "START", "END"
    static let buttonLabel:   CGFloat = 2.0   // "Create Account", tracked CTAs
    static let overline:      CGFloat = 1.0   // matches Typography.overline

    // MARK: - Body
    static let body:          CGFloat = 0.3
    static let bodyTight:     CGFloat = 0.1
    static let caption:       CGFloat = 0.2

    // MARK: - Monospaced / time
    static let time:          CGFloat = 0.5   // HH:mm time labels in rows
    static let mono:          CGFloat = 0.0

    // MARK: - Zero
    static let none:          CGFloat = 0.0
}
