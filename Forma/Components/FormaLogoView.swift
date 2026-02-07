//
//  FormaLogoView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/6/26.
//

import UIKit

class FormaLogoView: UIView {
    
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView(image: .formaLogo)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        imageView.backgroundColor = .backgroundSecondary
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    init(size: CGSize) {
        super.init(frame: .zero)
        showLogo(size)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func showLogo(_ size: CGSize) {
        addSubview(logoImageView)
        
        NSLayoutConstraint.activate([
            
            logoImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: size.width),
            logoImageView.heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
}
