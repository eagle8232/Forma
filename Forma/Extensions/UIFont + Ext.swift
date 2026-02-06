//
//  UIFont + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import Foundation
import UIKit

extension UIFont {
    
    static func textFont(weight: FormaFonts, size: CGFloat, italic: Bool = false) -> UIFont {
        guard let customFont = UIFont(name: italic ? weight.italic : weight.rawValue, size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return customFont
    }
}
