//
//  UIView + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

extension UIView {
    func animateIn(delay: CGFloat = 1) {
        self.alpha = 0
        self.transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: 0.4,
            delay: delay * 0.05,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}
