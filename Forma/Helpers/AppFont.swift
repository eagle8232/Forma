import SwiftUI

enum AppFont {
    static func display(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: mapWeight(weight), design: .default)
    }
    static func displayItalic(_ size: CGFloat) -> Font {
        .system(size: size, weight: .regular, design: .serif).italic()
    }
    static func ui(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: mapWeight(weight), design: .default)
    }
    static func uiMono(_ size: CGFloat) -> Font {
        .system(size: size, weight: mapWeight(.light), design: .monospaced)
    }
    
    private static func mapWeight(_ weight: Font.Weight) -> Font.Weight {
        switch weight {
        case .ultraLight: return .thin
        case .thin: return .light
        case .light: return .regular
        case .regular: return .medium
        case .medium: return .semibold
        case .semibold: return .bold
        case .bold: return .bold
        case .heavy: return .heavy
        case .black: return .black
        default: return .medium
        }
    }
}

extension Typography {
    var font: Font {
        switch self {
        case .displayLarge:     return .system(size: 38, weight: .semibold)
        case .displayMedium:   return .system(size: 32, weight: .semibold)
        case .displaySmall:    return .system(size: 24, weight: .semibold)
        case .heading1:        return .system(size: 28, weight: .bold)
        case .heading2:        return .system(size: 22, weight: .bold)
        case .heading3:        return .system(size: 18, weight: .semibold)
        case .bodyLarge:       return .system(size: 17, weight: .medium)
        case .bodyMedium:      return .system(size: 15, weight: .medium)
        case .bodySmall:       return .system(size: 13, weight: .medium)
        case .buttonLarge:     return .system(size: 17, weight: .bold)
        case .buttonMedium:    return .system(size: 15, weight: .semibold)
        case .label:           return .system(size: 14, weight: .semibold)
        case .caption:         return .system(size: 12, weight: .medium)
        case .overline:        return .system(size: 10, weight: .semibold)
        case .monospacedLarge: return .system(size: 17, weight: .medium, design: .monospaced)
        case .monospacedMedium: return .system(size: 15, weight: .medium, design: .monospaced)
        case .monospacedSmall: return .system(size: 13, weight: .medium, design: .monospaced)
        case .displayThin:     return .system(size: 56, weight: .light)
        case .displayThinLarge: return .system(size: 64, weight: .light)
        case .wordmark:        return .system(size: 10, weight: .thin)
        case .microTracked:    return .system(size: 10, weight: .regular)
        case .ultraLight:      return .system(size: 15, weight: .light)
        case .ultraLightSmall: return .system(size: 13, weight: .light)
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
