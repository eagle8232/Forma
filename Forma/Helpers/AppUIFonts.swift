//
//  FormaFonts.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import UIKit

enum Typography {
    
    // MARK: - Display (Playfair Display - for hero moments)
    case displayLarge        // 38pt - Onboarding titles, hero headlines
    case displayMedium       // 32pt - Feature highlights
    case displaySmall        // 24pt - Section emphasis
    
    // MARK: - Headings (System Font - for structure)
    case heading1            // 28pt - Main screen titles
    case heading2            // 22pt - Card titles
    case heading3            // 18pt - Subsection headers
    
    // MARK: - Body (System Font - for content)
    case bodyLarge           // 17pt - Primary reading text
    case bodyMedium          // 15pt - Secondary text
    case bodySmall           // 13pt - Tertiary text
    
    // MARK: - UI Elements (System Font - for interface)
    case buttonLarge         // 17pt - Primary CTAs
    case buttonMedium        // 15pt - Secondary buttons
    case label               // 14pt - Form labels, tags
    case caption             // 12pt - Metadata, timestamps
    case overline            // 10pt - Category labels, badges
    
    case monospacedLarge      // 17pt - Code snippets, if needed
    case monospacedMedium     // 15pt - Smaller code snippets
    case monospacedSmall      // 13pt - Inline code or annotations
    
    case displayThin        // 56pt thin  — auth headline "let's go"
    case displayThinLarge   // 64pt thin  — generation count numeral
    case wordmark           // 10pt ultraLight — "FORMA"
    case microTracked       // 10pt light — "THINKING", "ACTIVITIES"
    case ultraLight         // 15pt ultraLight — sublines, Google button
    case ultraLightSmall    // 13pt ultraLight — body notes, footer
    
    // MARK: - Computed Properties
    
    var uiFont: UIFont {
        switch self {
        case .displayLarge:       return UIFont.systemFont(ofSize: 38, weight: .medium)
        case .displayMedium:      return UIFont.systemFont(ofSize: 32, weight: .medium)
        case .displaySmall:       return UIFont.systemFont(ofSize: 24, weight: .medium)
            
        case .heading1:           return .systemFont(ofSize: 28, weight: .bold)
        case .heading2:           return .systemFont(ofSize: 22, weight: .bold)
        case .heading3:           return .systemFont(ofSize: 18, weight: .semibold)
    
        case .bodyLarge:          return .systemFont(ofSize: 17, weight: .regular)
        case .bodyMedium:         return .systemFont(ofSize: 15, weight: .regular)
        case .bodySmall:          return .systemFont(ofSize: 13, weight: .regular)

        case .buttonLarge:        return .systemFont(ofSize: 17, weight: .semibold)
        case .buttonMedium:       return .systemFont(ofSize: 15, weight: .medium)
        case .label:              return .systemFont(ofSize: 14, weight: .medium)
        case .caption:            return .systemFont(ofSize: 12, weight: .regular)
        case .overline:           return .systemFont(ofSize: 10, weight: .medium)
        
        case .monospacedLarge:    return .monospacedSystemFont(ofSize: 17, weight: .regular)
        case .monospacedMedium:   return .monospacedSystemFont(ofSize: 15, weight: .regular)
        case .monospacedSmall:    return .monospacedSystemFont(ofSize: 13, weight: .regular)
            
        case .displayThin:        return .systemFont(ofSize: 56, weight: .thin)
        case .displayThinLarge:   return .systemFont(ofSize: 64, weight: .thin)
        case .wordmark:           return .systemFont(ofSize: 10, weight: .ultraLight)
        case .microTracked:       return .systemFont(ofSize: 10, weight: .light)
        case .ultraLight:         return .systemFont(ofSize: 15, weight: .ultraLight)
        case .ultraLightSmall:    return .systemFont(ofSize: 13, weight: .ultraLight)
            
            
        }
    }
    
    var lineHeight: CGFloat {
        switch self {
        case .displayLarge: return 48
        case .displayMedium: return 40
        case .displaySmall: return 32
        case .heading1: return 36
        case .heading2: return 28
        case .heading3: return 24
        case .bodyLarge: return 24
        case .bodyMedium: return 22
        case .bodySmall: return 20
        case .monospacedLarge: return 24
        case .monospacedMedium: return 22
        case .monospacedSmall: return 20
        case .buttonLarge, .buttonMedium: return 20
        case .label: return 20
        case .caption: return 16
        case .overline: return 16
        case .displayThin, .displayThinLarge: return -2.0
        case .wordmark:                       return 6.0
        case .microTracked:                   return 3.0
        case .ultraLight, .ultraLightSmall:   return 0.1
        }
    }
    
    var letterSpacing: CGFloat {
        switch self {
        case .displayLarge, .displayMedium, .displaySmall:
            return -0.5  // Tighter for display
        case .overline:
            return 1.0   // Wider for all-caps labels
        default:
            return 0.0
        }
    }
}

// MARK: - UIFont Extension

extension UIFont {
    
    /// Primary way to access typography system
    /// Usage: label.font = .typography(.displayLarge)
    static func typography(_ style: Typography) -> UIFont {
        return style.uiFont
    }
}

// MARK: - NSAttributedString Extension

extension NSAttributedString {
    
    /// Create attributed string with typography style
    static func styled(
        _ text: String,
        typography: Typography,
        color: UIColor = .label,
        alignment: NSTextAlignment = .left
    ) -> NSAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = typography.lineHeight - typography.uiFont.lineHeight
        paragraphStyle.alignment = alignment
        
        return NSAttributedString(
            string: text,
            attributes: [
                .font: typography.uiFont,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .kern: typography.letterSpacing
            ]
        )
    }
}
