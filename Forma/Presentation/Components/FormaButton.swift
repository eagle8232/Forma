//
//  FormaButton.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/13/26.
//

import UIKit

enum FormaButtonStyle {
    case text           // Text only, no background
    case rectangle      // Rounded rectangle background
    case capsule        // Fully rounded (pill shape)
}

final class FormaButton: UIButton {
    
    // MARK: - Configuration
    struct Configuration {
        var title: String?
        var icon: UIImage?
        var iconPosition: IconPosition = .leading
        var style: FormaButtonStyle = .rectangle
        var backgroundColor: UIColor = .accent
        var titleColor: UIColor = .white
        var borderColor: UIColor?
        var borderWidth: CGFloat = 0
        var cornerRadius: CGFloat? = nil // nil = auto based on style
        var contentPadding: UIEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        var iconSize: CGFloat = 20
        var iconSpacing: CGFloat = 8
        
        enum IconPosition {
            case leading  // Icon before text
            case trailing // Icon after text
            case only     // Icon only, no text
        }
    }
    
    // MARK: - Properties
    private var config: Configuration
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let iconImageView = UIImageView()
    private let customTitleLabel = UILabel()
    
    private var contentStackView: UIStackView!
    private var isLoading = false
    
    // Store original content for restoring after loading
    private var originalTitle: String?
    private var originalIcon: UIImage?
    
    // MARK: - Initialization
    init(configuration: Configuration) {
        self.config = configuration
        super.init(frame: .zero)
        setup()
    }
    
    convenience init(
        title: String? = nil,
        icon: UIImage? = nil,
        style: FormaButtonStyle = .rectangle
    ) {
        let config = Configuration(
            title: title,
            icon: icon,
            style: style
        )
        self.init(configuration: config)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(configuration:) instead")
    }
    
    // MARK: - Setup
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        setupStackView()
        setupContent()
        applyStyle()
        setupActivityIndicator()
        setupInteractions()
    }
    
    private func setupStackView() {
        contentStackView = UIStackView()
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = config.iconSpacing
        contentStackView.isUserInteractionEnabled = false
        
        addSubview(contentStackView)
        
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: topAnchor, constant: config.contentPadding.top),
            contentStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: config.contentPadding.left),
            contentStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -config.contentPadding.right),
            contentStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -config.contentPadding.bottom)
        ])
    }
    
    private func setupContent() {
        // Clear existing arranged subviews
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Setup icon
        if let icon = config.icon {
            iconImageView.image = icon.withRenderingMode(.alwaysTemplate)
            iconImageView.tintColor = config.titleColor
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                iconImageView.widthAnchor.constraint(equalToConstant: config.iconSize),
                iconImageView.heightAnchor.constraint(equalToConstant: config.iconSize)
            ])
        }
        
        // Setup title label
        if let title = config.title {
            customTitleLabel.text = title
            customTitleLabel.font = UIFont.typography(.buttonLarge)
            customTitleLabel.textColor = config.titleColor
            customTitleLabel.textAlignment = .center
            customTitleLabel.numberOfLines = 1
        }
        
        // Add to stack based on configuration
        switch config.iconPosition {
        case .leading:
            if config.icon != nil {
                contentStackView.addArrangedSubview(iconImageView)
            }
            if config.title != nil {
                contentStackView.addArrangedSubview(customTitleLabel)
            }
            
        case .trailing:
            if config.title != nil {
                contentStackView.addArrangedSubview(customTitleLabel)
            }
            if config.icon != nil {
                contentStackView.addArrangedSubview(iconImageView)
            }
            
        case .only:
            if config.icon != nil {
                contentStackView.addArrangedSubview(iconImageView)
            }
        }
    }
    
    private func applyStyle() {
        switch config.style {
        case .text:
            backgroundColor = .clear
            layer.cornerRadius = 0
            
        case .rectangle:
            backgroundColor = config.backgroundColor
            layer.cornerRadius = config.cornerRadius ?? 12
            layer.cornerCurve = .continuous
            
        case .capsule:
            backgroundColor = config.backgroundColor
            // Capsule radius will be set in layoutSubviews
        }
        
        // Border
        if let borderColor = config.borderColor {
            layer.borderColor = borderColor.cgColor
            layer.borderWidth = config.borderWidth
        }
        
        // Shadow (only for filled buttons)
        if config.style != .text {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 2)
            layer.shadowRadius = 4
            layer.shadowOpacity = 0.1
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = config.titleColor
        
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    private func setupInteractions() {
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update capsule corner radius
        if config.style == .capsule {
            layer.cornerRadius = bounds.height / 2
        }
    }
    
    // MARK: - Animations
    @objc private func touchDown() {
        SoundManager.shared.playSound(.buttonTap)
        SoundManager.shared.playHaptic(.light)
        
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
                self.alpha = 0.8
            }
        )
    }
    
    @objc private func touchUp() {
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.curveEaseOut, .allowUserInteraction],
            animations: {
                self.transform = .identity
                self.alpha = 1.0
            }
        )
    }
    
    // MARK: - Loading State
    func setLoading(_ loading: Bool) {
        guard isLoading != loading else { return }
        isLoading = loading
        
        if loading {
            // Store original content
            originalTitle = config.title
            originalIcon = config.icon
            
            // Hide content
            contentStackView.isHidden = true
            
            // Show activity indicator
            activityIndicator.startAnimating()
            isEnabled = false
            
        } else {
            // Restore content
            contentStackView.isHidden = false
            
            // Hide activity indicator
            activityIndicator.stopAnimating()
            isEnabled = true
        }
    }
    
    // MARK: - Public Configuration Methods
    func updateConfiguration(_ configuration: Configuration) {
        self.config = configuration
        setupContent()
        applyStyle()
    }
    
    func setTitle(_ title: String?) {
        config.title = title
        customTitleLabel.text = title
        setupContent()
    }
    
    func setIcon(_ icon: UIImage?) {
        config.icon = icon
        iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
        setupContent()
    }
    
    func setStyle(_ style: FormaButtonStyle) {
        config.style = style
        applyStyle()
        setNeedsLayout()
    }
    
    func setBackgroundColor(_ color: UIColor) {
        config.backgroundColor = color
        backgroundColor = color
    }
    
    func setTitleColor(_ color: UIColor) {
        config.titleColor = color
        customTitleLabel.textColor = color
        iconImageView.tintColor = color
        activityIndicator.color = color
    }
    
    func setBorder(color: UIColor, width: CGFloat) {
        config.borderColor = color
        config.borderWidth = width
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    func setCornerRadius(_ radius: CGFloat) {
        config.cornerRadius = radius
        if config.style == .rectangle {
            layer.cornerRadius = radius
        }
    }
    
    // MARK: - Disabled State
    override var isEnabled: Bool {
        didSet {
            alpha = isEnabled ? 1.0 : 0.5
        }
    }
}

// MARK: - Convenience Factory
extension FormaButton {
    
    /// Primary button with title
    static func primary(title: String) -> FormaButton {
        FormaButton(configuration: .init(
            title: title,
            style: .capsule,
            backgroundColor: .accent,
            titleColor: .white
        ))
    }
    
    /// Secondary button with border
    static func secondary(title: String) -> FormaButton {
        FormaButton(configuration: .init(
            title: title,
            style: .capsule,
            backgroundColor: .clear,
            titleColor: .accent,
            borderColor: .accent,
            borderWidth: 1.5
        ))
    }
    
    /// Text-only button
    static func text(title: String) -> FormaButton {
        FormaButton(configuration: .init(
            title: title,
            style: .text,
            backgroundColor: .clear,
            titleColor: .accent
        ))
    }
    
    /// Icon-only button
    static func icon(_ icon: UIImage, style: FormaButtonStyle = .capsule) -> FormaButton {
        FormaButton(configuration: .init(
            icon: icon,
            iconPosition: .only,
            style: style,
            backgroundColor: .accent,
            titleColor: .white,
            contentPadding: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        ))
    }
    
    /// Button with icon and title
    static func withIcon(
        title: String,
        icon: UIImage,
        iconPosition: Configuration.IconPosition = .leading
    ) -> FormaButton {
        FormaButton(configuration: .init(
            title: title,
            icon: icon,
            iconPosition: iconPosition,
            style: .capsule,
            backgroundColor: .accent,
            titleColor: .white
        ))
    }
}
