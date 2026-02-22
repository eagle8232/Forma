//
//  FormaTextField.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import UIKit

public class FormaTextField: UIView {
    
    // MARK: - Configuration
    
    public struct Configuration {
        public var leftIcon: UIImage?
        public var keyboardType: UIKeyboardType
        public var returnKeyType: UIReturnKeyType
        
        public init(
            leftIcon: UIImage? = nil,
            keyboardType: UIKeyboardType = .default,
            returnKeyType: UIReturnKeyType = .default
        ) {
            self.leftIcon = leftIcon
            self.keyboardType = keyboardType
            self.returnKeyType = returnKeyType
        }
    }
    
    // MARK: - UI Components
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public let textField: UITextField = {
        let field = UITextField()
        field.font = .systemFont(ofSize: 16)
        field.textColor = .label
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    // MARK: - Properties
    
    /// Allows direct access to read or write the text, just like a standard UITextField
    public var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    /// Allows setting the text field's delegate directly from the parent view
    public var delegate: UITextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }
    
    // MARK: - Initialization
    
    public init(placeholder: String, configuration: Configuration) {
        super.init(frame: .zero)
        
        setupView()
        configure(with: placeholder, configuration: configuration)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray4.cgColor
        
        addSubview(stackView)
        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(textField)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            // Fix icon size
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    private func configure(with placeholder: String, configuration: Configuration) {
        textField.placeholder = placeholder
        textField.keyboardType = configuration.keyboardType
        textField.returnKeyType = configuration.returnKeyType
        
        if let icon = configuration.leftIcon {
            iconImageView.image = icon
            iconImageView.isHidden = false
        } else {
            iconImageView.isHidden = true
        }
    }
    
    // MARK: - Public Methods
    
    /// Sets the text of the internal text field (Kept for compatibility with your first snippet)
    public func setText(_ text: String?) {
        self.text = text
    }
}
