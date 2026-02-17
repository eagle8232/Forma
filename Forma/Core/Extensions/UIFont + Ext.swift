//
//  UIFont + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import Foundation
import UIKit

extension UIFont {
    
    func withItalicTrait() -> UIFont {
        // Common italic font name patterns
        let currentName = fontName

        // Try common italic naming patterns
        let italicPatterns = [
            "-Italic",
            "-It",
            "Italic"
        ]
        
        // Check if already italic
        if currentName.contains("Italic") || currentName.contains("-It") {
            return self
        }
        
        // Try to find italic variant
        for pattern in italicPatterns {
            let italicName = currentName + pattern
            if let italicFont = UIFont(name: italicName, size: pointSize) {
                return italicFont
            }
        }
        
        // Last resort: Use system italic if available
        if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic]) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        
        // If all else fails, return original font
        print("⚠️ Could not create italic variant for font: \(currentName)")
        return self
    }
}
