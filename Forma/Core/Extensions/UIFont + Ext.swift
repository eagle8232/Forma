//
//  UIFont + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import Foundation
import UIKit

extension UIFont {
    
    static func customFont(type: String, size: CGFloat) -> UIFont {
        guard let customFont = UIFont(name: type, size: size) else {
            return UIFont.systemFont(ofSize: 25)
        }
        return customFont
    }
}
