import UIKit

extension UIFont {
    func withItalicTrait() -> UIFont {
        let currentName = fontName
        let italicPatterns = ["-Italic", "-It", "Italic"]
        
        if currentName.contains("Italic") || currentName.contains("-It") {
            return self
        }
        
        for pattern in italicPatterns {
            let italicName = currentName + pattern
            if let italicFont = UIFont(name: italicName, size: pointSize) {
                return italicFont
            }
        }
        
        if let descriptor = fontDescriptor.withSymbolicTraits([.traitItalic]) {
            return UIFont(descriptor: descriptor, size: pointSize)
        }
        
        return self
    }
}
