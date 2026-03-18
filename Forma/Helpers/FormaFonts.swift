//
//  FormaFonts.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/15/26.
//

import SwiftUI

// MARK: - Typography System (SwiftUI)

extension Typography {

    var font: Font {
        switch self {
        case .displayLarge:    return .system(size: 38, weight: .medium)
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
        case .monospacedMedium:return .system(size: 15, weight: .regular, design: .monospaced)
        case .monospacedSmall: return .system(size: 13, weight: .regular, design: .monospaced)
        }
    }

    // MARK: - Tracking (letter spacing)

    var tracking: CGFloat {
        switch self {
        case .displayLarge, .displayMedium, .displaySmall: return -0.5
        case .overline:                                     return 1.0
        default:                                            return 0.0
        }
    }

    // MARK: - Line spacing

    var lineSpacing: CGFloat {
        switch self {
        case .displayLarge:  return 10
        case .displayMedium: return 8
        case .displaySmall:  return 8
        case .heading1:      return 8
        case .heading2:      return 6
        case .heading3:      return 6
        case .bodyLarge:     return 7
        case .bodyMedium:    return 7
        case .bodySmall:     return 7
        default:             return 4
        }
    }
}

// MARK: - View Modifier

private struct TypographyModifier: ViewModifier {
    let style: Typography

    func body(content: Content) -> some View {
        content
            .font(style.font)
            .tracking(style.tracking)
            .lineSpacing(style.lineSpacing)
    }
}

// MARK: - View Extension

extension View {

    /// Usage: Text("Hello").customFont(.displayLarge)
    func customFont(_ style: Typography) -> some View {
        modifier(TypographyModifier(style: style))
    }
}

// MARK: - Text Extension (convenience)

extension Text {

    /// Usage: Text("Hello").customFont(.heading1)
    func customFont(_ style: Typography) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
    }
}
