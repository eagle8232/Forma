import SwiftUI

enum AppColor {
    static let accentPrimary   = Color(red: 0.55, green: 0.40, blue: 1.00)
    static let accentSecondary = Color(red: 0.30, green: 0.55, blue: 1.00)
    static let accent = Color.hex("#A259FF")
    static let accentLow = accent.opacity(0.1)

    static let accentGradient = LinearGradient(
        colors: [accentPrimary, accentSecondary],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let accentFadeGradient = LinearGradient(
        colors: [accentPrimary.opacity(AppOpacity.accentRuleLead), accentPrimary.opacity(0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let background = Color.backgroundPrimary
    static let white      = Color.white

    static let surface1 = Color.hex("#101010")
    static let surface2 = Color.hex("#161616")
    static let surface3 = Color.hex("#1E1E1E")
    static let border = Color.white.opacity(0.07)
    static let border2 = Color.white.opacity(0.11)

    static let surfaceFill        = Color.white.opacity(AppOpacity.surfaceFill)
    static let surfaceFillStrong  = Color.white.opacity(AppOpacity.surfaceFillStrong)
    static let surfaceBorder      = Color.white.opacity(AppOpacity.surfaceBorder)
    static let surfaceDivider     = Color.white.opacity(AppOpacity.surfaceDivider)

    static let textPrimary = Color.white.opacity(AppOpacity.textPrimary)
    static let textSecondary = Color.white.opacity(AppOpacity.textSecondary)
    static let textTertiary = Color.white.opacity(AppOpacity.textTertiary)
    static let textDisabled = Color.white.opacity(AppOpacity.textDisabled)
    static let textWordmark = Color.white.opacity(AppOpacity.textWordmark)
    static let textMuted = Color.hex("#555555")
    static let textMuted2 = Color.hex("#2A2A2A")

    static let gold = Color.hex("#C9A96E")
    static let goldLow = gold.opacity(0.09)

    static let green = Color.hex("#4CD97B")
    static let greenLow = green.opacity(0.1)

    static let errorFill       = Color(red: 1.0, green: 0.2,  blue: 0.3)
    static let errorText       = Color(red: 1.0, green: 0.45, blue: 0.45)
    static let errorBorder     = errorFill.opacity(0.25)
    static let errorBackground = errorFill.opacity(0.10)
    static let destructive = errorFill.opacity(0.7)

    static let glowBottom = RadialGradient(
        colors: [accentPrimary.opacity(0.11), .clear],
        center: .init(x: 0.5, y: 1.15),
        startRadius: 0,
        endRadius: 420
    )

    static let logoGlow = accentPrimary.opacity(0.5)
}

enum AppOpacity {
    static let textPrimary:   Double = 0.92
    static let textSecondary: Double = 0.55
    static let textTertiary:  Double = 0.28
    static let textDisabled:  Double = 0.20
    static let textWordmark:  Double = 0.30
    static let textMicro:     Double = 0.18
    static let textHint:      Double = 0.15

    static let surfaceFill:       Double = 0.035
    static let surfaceFillStrong: Double = 0.055
    static let surfaceBorder:     Double = 0.08
    static let surfaceDivider:    Double = 0.06

    static let accentRuleLead: Double = 0.9
    static let accentIcon:     Double = 0.6
    static let accentSubtle:   Double = 0.1

    static let pressedScale:    Double = 0.82
    static let disabledText:    Double = 0.20
    static let loadingSpinner:  Double = 0.45

    static let grainDensity:  Double = 0.14
    static let grainAlphaMin: Double = 0.008
    static let grainAlphaMax: Double = 0.063

    static let dragHandle:    Double = 0.12
    static let rowDivider:    Double = 0.055
    static let shimmer:       Double = 0.07
    static let statusDotCore: Double = 0.55
    static let statusDotRing: Double = 0.15
}

extension Color {
    static func hex(_ value: String) -> Color {
        Color(uiColor: UIColor(hex: value))
    }
}
