import UIKit

extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text else { return }
        attributedText = NSAttributedString(string: text, attributes: [
            .kern: spacing,
            .foregroundColor: textColor as Any,
            .font: font as Any
        ])
    }
}

