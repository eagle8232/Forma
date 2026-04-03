import SwiftUI

enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .light) -> Font {
        .custom("Cormorant Garamond", size: size).weight(weight)
    }
    static func displayItalic(_ size: CGFloat) -> Font {
        .custom("Cormorant Garamond", size: size).italic()
    }
    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .custom("Manrope", size: size).weight(weight)
    }
    static func uiMono(_ size: CGFloat) -> Font {
        .custom("Manrope", size: size).weight(.light).monospaced()
    }
}

extension Typography {
    var font: Font {
        switch self {
        case .displayLarge:     return .system(size: 38, weight: .medium)
        case .displayMedium:   return .system(size: 32, weight: .medium)
        case .displaySmall:    return .system(size: 24, weight: .medium)
        case .heading1:        return .system(size: 28, weight: .bold)
        case .heading2:        return .system(size: 22, weight: .bold)
        case .heading3:        return .system(size: 18, weight: .semibold)
        case .bodyLarge:       return .system(size: 17, weight: .regular)
        case .bodyMedium:      return .system(size: 15, weight: .regular)
        case .bodySmall:       return .system(size: 13, weight: .regular)
        case .buttonLarge:     return .system(size: 17, weight: .semibold)
        case .buttonMedium:    return .system(size: 15, weight: .medium)
        case .label:           return .system(size: 14, weight: .medium)
        case .caption:         return .system(size: 12, weight: .regular)
        case .overline:        return .system(size: 10, weight: .medium)
        case .monospacedLarge: return .system(size: 17, weight: .regular, design: .monospaced)
        case .monospacedMedium: return .system(size: 15, weight: .regular, design: .monospaced)
        case .monospacedSmall: return .system(size: 13, weight: .regular, design: .monospaced)
        case .displayThin:     return .system(size: 56, weight: .thin)
        case .displayThinLarge: return .system(size: 64, weight: .thin)
        case .wordmark:        return .system(size: 10, weight: .ultraLight)
        case .microTracked:    return .system(size: 10, weight: .light)
        case .ultraLight:      return .system(size: 15, weight: .ultraLight)
        case .ultraLightSmall: return .system(size: 13, weight: .ultraLight)
        }
    }

    var tracking: CGFloat {
        switch self {
        case .displayLarge, .displayMedium, .displaySmall: return -0.5
        case .overline: return 1.0
        default: return 0.0
        }
    }

    var lineSpacing: CGFloat {
        switch self {
        case .displayLarge, .displayMedium, .displaySmall: return 8
        case .heading1, .heading2, .heading3: return 6
        case .bodyLarge, .bodyMedium, .bodySmall: return 7
        default: return 4
        }
    }
}

private struct TypographyModifier: ViewModifier {
    let style: Typography

    func body(content: Content) -> some View {
        content.font(style.font).tracking(style.tracking).lineSpacing(style.lineSpacing)
    }
}

extension View {
    func customFont(_ style: Typography) -> some View {
        modifier(TypographyModifier(style: style))
    }
}

extension Text {
    func customFont(_ style: Typography) -> some View {
        self.font(style.font)
    }
}
