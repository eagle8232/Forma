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
    case overline            // 11pt - Category labels, badges
    
    // MARK: - Computed Properties
    
    var font: UIFont {
        switch self {
        // Display (Playfair Display)
        case .displayLarge:
            return UIFont(name: PlayfairDisplay.bold.fontName, size: 38) ?? .systemFont(ofSize: 38, weight: .bold)
        case .displayMedium:
            return UIFont(name: PlayfairDisplay.bold.fontName, size: 32) ?? .systemFont(ofSize: 32, weight: .bold)
        case .displaySmall:
            return UIFont(name: PlayfairDisplay.bold.fontName, size: 24) ?? .systemFont(ofSize: 24, weight: .bold)
            
        // Headings (System)
        case .heading1:
            return .systemFont(ofSize: 28, weight: .bold)
        case .heading2:
            return .systemFont(ofSize: 22, weight: .semibold)
        case .heading3:
            return .systemFont(ofSize: 18, weight: .semibold)
            
        // Body (System)
        case .bodyLarge:
            return .systemFont(ofSize: 17, weight: .regular)
        case .bodyMedium:
            return .systemFont(ofSize: 15, weight: .regular)
        case .bodySmall:
            return .systemFont(ofSize: 13, weight: .regular)
            
        // UI (System)
        case .buttonLarge:
            return .systemFont(ofSize: 17, weight: .semibold)
        case .buttonMedium:
            return .systemFont(ofSize: 15, weight: .medium)
        case .label:
            return .systemFont(ofSize: 14, weight: .medium)
        case .caption:
            return .systemFont(ofSize: 12, weight: .regular)
        case .overline:
            return .systemFont(ofSize: 11, weight: .medium)
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
        case .buttonLarge, .buttonMedium: return 20
        case .label: return 20
        case .caption: return 16
        case .overline: return 16
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

// MARK: - Font Families

/// Playfair Display font family (Display/Decorative)
enum PlayfairDisplay: String {
    case regular = "PlayfairDisplay-Regular"
    case italic = "PlayfairDisplay-Italic"
    case medium = "PlayfairDisplay-Medium"
    case mediumItalic = "PlayfairDisplay-MediumItalic"
    case semiBold = "PlayfairDisplay-SemiBold"
    case semiBoldItalic = "PlayfairDisplay-SemiBoldItalic"
    case bold = "PlayfairDisplay-Bold"
    case boldItalic = "PlayfairDisplay-BoldItalic"
    case extraBold = "PlayfairDisplay-ExtraBold"
    case extraBoldItalic = "PlayfairDisplay-ExtraBoldItalic"
    case black = "PlayfairDisplay-Black"
    case blackItalic = "PlayfairDisplay-BlackItalic"
    
    var fontName: String {
        return rawValue
    }
    
    /// Get font at specific size
    func font(size: CGFloat) -> UIFont {
        return UIFont(name: fontName, size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }
}

// MARK: - UIFont Extension

extension UIFont {
    
    /// Primary way to access typography system
    /// Usage: label.font = .typography(.displayLarge)
    static func typography(_ style: Typography) -> UIFont {
        return style.font
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
        paragraphStyle.lineSpacing = typography.lineHeight - typography.font.lineHeight
        paragraphStyle.alignment = alignment
        
        return NSAttributedString(
            string: text,
            attributes: [
                .font: typography.font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .kern: typography.letterSpacing
            ]
        )
    }
}
