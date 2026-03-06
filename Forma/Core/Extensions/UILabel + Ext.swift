//
//  UILabel + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/2/26.
//

import UIKit

extension UILabel {
    func letterSpacing(_ spacing: CGFloat) {
        guard let text else { return }
        let attributed = NSAttributedString(string: text, attributes: [
            .kern: spacing,
            .foregroundColor: self.textColor as Any,
            .font: self.font as Any
        ])
        attributedText = attributed
    }
}

