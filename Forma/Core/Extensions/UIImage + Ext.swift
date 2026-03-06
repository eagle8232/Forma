//
//  UIImage + Ext.swift
//  Forma
//
//  Created by Vusal Nuriyev on 3/2/26.
//

import UIKit

extension UIImage {
    static func gradientImage(bounds: CGRect, colors: [UIColor], startPoint: CGPoint, endPoint: CGPoint) -> UIImage? {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        
        let imageRenderer = UIGraphicsImageRenderer(size: gradientLayer.bounds.size)
        var gradientImage: UIImage?
        imageRenderer.image { context in
            gradientLayer.render(in: context.cgContext )
            let image = UIGraphicsGetImageFromCurrentImageContext()
            gradientImage = image
        }
        
        return gradientImage
    }
}
