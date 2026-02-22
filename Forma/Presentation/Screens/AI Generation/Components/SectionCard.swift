//
//  SectionCard.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/20/26.
//

import UIKit

final class SectionCard: UIView {

    private let contentContainer: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 12
        return s
    }()

    init(title: String, icon: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false

        backgroundColor = UIColor(white: 1, alpha: 0.05)
        layer.cornerRadius = 20
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: 1, alpha: 0.08).cgColor

        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        blur.layer.cornerRadius = 20
        blur.clipsToBounds = true
        blur.isUserInteractionEnabled = false
        insertSubview(blur, at: 0)

        let conf = UIImage.SymbolConfiguration(pointSize: 11, weight: .semibold)
        let headerIcon = UIImageView(image: UIImage(systemName: icon, withConfiguration: conf))
        headerIcon.translatesAutoresizingMaskIntoConstraints = false
        headerIcon.tintColor = UIColor.accent.withAlphaComponent(0.8)
        headerIcon.contentMode = .scaleAspectFit

        let headerLabel = UILabel()
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.text = title
        headerLabel.font = UIFont.monospacedSystemFont(ofSize: 10, weight: .semibold)
        headerLabel.textColor = UIColor(white: 1, alpha: 0.35)

        let headerStack = UIStackView(arrangedSubviews: [headerIcon, headerLabel])
        headerStack.translatesAutoresizingMaskIntoConstraints = false
        headerStack.axis = .horizontal
        headerStack.spacing = 8
        headerStack.alignment = .center

        let divider = UIView()
        divider.translatesAutoresizingMaskIntoConstraints = false
        divider.backgroundColor = UIColor(white: 1, alpha: 0.07)

        addSubview(blur)
        addSubview(headerStack)
        addSubview(divider)
        addSubview(contentContainer)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            headerStack.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            headerStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
            headerIcon.widthAnchor.constraint(equalToConstant: 14),
            headerIcon.heightAnchor.constraint(equalToConstant: 14),

            divider.topAnchor.constraint(equalTo: headerStack.bottomAnchor, constant: 14),
            divider.leadingAnchor.constraint(equalTo: leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1),

            contentContainer.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 16),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }

    required init?(coder: NSCoder) { fatalError() }

    func addContent(_ views: [UIView]) {
        views.forEach { contentContainer.addArrangedSubview($0) }
    }
}


