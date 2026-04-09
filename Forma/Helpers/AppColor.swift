import SwiftUI

enum AppColor {
    static let accentPrimary   = Color.adaptive(dark: Color.white, light: Color.black)
    static let accent = accentPrimary
    static let accentLow = accentPrimary.opacity(0.1)

    static let accentFadeGradient = LinearGradient(
        colors: [accentPrimary.opacity(AppOpacity.accentRuleLead), accentPrimary.opacity(0)],
        startPoint: .leading,
        endPoint: .trailing
    )

    static var background: Color { Color.adaptive(dark: Color.hex("#060606"), light: Color.white) }
    static var secondaryBackground: Color { Color.adaptive(dark: Color.hex("#0E0E0E"), light: Color.hex("#F5F5F7")) }
    static var tertiaryBackground: Color { Color.adaptive(dark: Color.hex("#141414"), light: Color.hex("#FFFFFF")) }
    static let white      = Color.white

    static var surface1: Color { Color.adaptive(dark: Color.hex("#1A1A1A"), light: Color.hex("#F5F5F7")) }
    static var surface2: Color { Color.adaptive(dark: Color.hex("#222222"), light: Color.hex("#FFFFFF")) }
    static var surface3: Color { Color.adaptive(dark: Color.hex("#2A2A2A"), light: Color.hex("#E5E5E5")) }
    static var border: Color { Color.adaptive(dark: Color.white.opacity(0.10), light: Color.black.opacity(0.1)) }
    static var border2: Color { Color.adaptive(dark: Color.white.opacity(0.15), light: Color.black.opacity(0.15)) }

    static var surfaceFill: Color { Color.adaptive(dark: Color.white.opacity(0.06), light: Color.black.opacity(0.05)) }
    static var surfaceFillStrong: Color { Color.adaptive(dark: Color.white.opacity(0.09), light: Color.black.opacity(0.08)) }
    static var surfaceBorder: Color { Color.adaptive(dark: Color.white.opacity(0.12), light: Color.black.opacity(0.12)) }
    static var surfaceDivider: Color { Color.adaptive(dark: Color.white.opacity(0.10), light: Color.black.opacity(0.1)) }

    static var textPrimary: Color { Color.adaptive(dark: Color.white, light: Color.black) }
    static var textSecondary: Color { Color.adaptive(dark: Color.white.opacity(0.75), light: Color.black.opacity(0.75)) }
    static var textTertiary: Color { Color.adaptive(dark: Color.white.opacity(0.50), light: Color.black.opacity(0.50)) }
    static var textDisabled: Color { Color.adaptive(dark: Color.white.opacity(0.35), light: Color.black.opacity(0.35)) }
    static var textWordmark: Color { Color.adaptive(dark: Color.white.opacity(0.50), light: Color.black.opacity(0.50)) }
    static var textMuted: Color { Color.adaptive(dark: Color.hex("#888888"), light: Color.hex("#666666")) }
    static var textMuted2: Color { Color.adaptive(dark: Color.hex("#505050"), light: Color.hex("#999999")) }

    static let gold = Color.hex("#A259FF")
    static let goldLow = gold.opacity(0.09)

    static let green = Color.hex("#4CD97B")
    static let greenLow = green.opacity(0.1)

    static let errorFill       = Color(red: 1.0, green: 0.2,  blue: 0.3)
    static let errorText       = Color(red: 1.0, green: 0.45, blue: 0.45)
    static let errorBorder     = errorFill.opacity(0.25)
    static let errorBackground = errorFill.opacity(0.10)
    static let destructive = errorFill.opacity(0.7)

    static var switchTrackOff: Color { Color.adaptive(dark: Color.hex("#333333"), light: Color.hex("#E0E0E0")) }

    static let glowBottom = RadialGradient(
        colors: [accentPrimary.opacity(0.11), .clear],
        center: .init(x: 0.5, y: 1.15),
        startRadius: 0,
        endRadius: 420
    )

    static let logoGlow = accentPrimary.opacity(0.5)
}

enum AppOpacity {
    static let textPrimary:   Double = 1.0
    static let textSecondary: Double = 0.75
    static let textTertiary:  Double = 0.50
    static let textDisabled:  Double = 0.35
    static let textWordmark:  Double = 0.50
    static let textMicro:     Double = 0.35
    static let textHint:      Double = 0.30

    static let surfaceFill:       Double = 0.06
    static let surfaceFillStrong: Double = 0.09
    static let surfaceBorder:     Double = 0.12
    static let surfaceDivider:    Double = 0.10

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
    
    static func adaptive(dark: Color, light: Color) -> Color {
        Color(uiColor: UIColor { traitCollection in
            if traitCollection.userInterfaceStyle == .dark {
                return UIColor(cgColor: dark.cgColor ?? UIColor.black.cgColor)
            } else {
                return UIColor(cgColor: light.cgColor ?? UIColor.white.cgColor)
            }
        })
    }
    
    static func adaptiveWhiteOpacity(_ darkOpacity: Double, lightOpacity: Double) -> Color {
        adaptive(dark: .white.opacity(darkOpacity), light: .black.opacity(lightOpacity))
    }
}
