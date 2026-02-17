//
//  FormaTextView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/10/26.
//

import UIKit

final class FormaTextView: UIView {
    
    // MARK: - Properties
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .clear
        addSubview(containerStackView)
        
        NSLayoutConstraint.activate([
            containerStackView.topAnchor.constraint(equalTo: topAnchor),
            containerStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    // MARK: - Public API
    
    /// Add a title (large, bold text)
    @discardableResult
    func addTitle(
        _ text: String,
        color: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left
    ) -> FormaTextView {
        let label = createLabel(
            text: text,
            font: .systemFont(ofSize: 32, weight: .bold),
            color: color,
            alignment: alignment
        )
        containerStackView.addArrangedSubview(label)
        return self
    }
    
    /// Add a heading (medium-large, semibold text)
    @discardableResult
    func addHeading(
        _ text: String,
        typography: Typography = .heading2,
        color: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        let label = createLabel(
            text: text,
            font: typography.font,
            color: color,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
        containerStackView.addArrangedSubview(label)
        return self
    }
    
    /// Add a title (large, bold text)
    @discardableResult
    func addTitle(
        _ text: String,
        typography: Typography = .heading1,
        color: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        let label = createLabel(
            text: text,
            font: typography.font,
            color: color,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
        containerStackView.addArrangedSubview(label)
        return self
    }

    /// Add a subtitle (medium text)
    @discardableResult
    func addSubtitle(
        _ text: String,
        typography: Typography = .bodyLarge,
        color: UIColor = .textSecondary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        let label = createLabel(
            text: text,
            font: typography.font,
            color: color,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
        containerStackView.addArrangedSubview(label)
        return self
    }

    /// Add body text (regular paragraph text)
    @discardableResult
    func addBody(
        _ text: String,
        typography: Typography = .bodyMedium,
        color: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        let label = createLabel(
            text: text,
            font: typography.font,
            color: color,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
        containerStackView.addArrangedSubview(label)
        return self
    }

    /// Add caption (small text)
    @discardableResult
    func addCaption(
        _ text: String,
        typography: Typography = .caption,
        color: UIColor = .textSecondary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        let label = createLabel(
            text: text,
            font: typography.font,
            color: color,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
        containerStackView.addArrangedSubview(label)
        return self
    }

    /// Add text with specific word(s) highlighted
    @discardableResult
    func addText(
        _ text: String,
        markWords: [(word: String, color: UIColor)],
        typography: Typography = .bodyMedium,
        baseColor: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        let label = UILabel()
        label.numberOfLines = text.count
        label.textAlignment = alignment

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: typography.font,
                .foregroundColor: baseColor
            ]
        )
        
        // Highlight marked words with color AND italic
        for (word, color) in markWords {
            let range = (text as NSString).range(of: word)
            if range.location != NSNotFound {
                // Change color
                attributedString.addAttribute(.foregroundColor, value: color, range: range)
                
                // Make italic with same font
                let italicFont = typography.font.withItalicTrait()
                attributedString.addAttribute(.font, value: italicFont, range: range)
            }
        }
        
        label.attributedText = attributedString
        containerStackView.addArrangedSubview(label)
        return self
    }

    // MARK: - Helper Methods

    private func createLabel(
        text: String,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment,
        lineSpacing: CGFloat = 2
    ) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        
        // Create paragraph style
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        // Create attributed string
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        label.attributedText = attributedString
        return label
    }
    /// Add custom attributed text with full control
    @discardableResult
    func addAttributedText(
        _ attributedString: NSAttributedString,
        alignment: NSTextAlignment = .left
    ) -> FormaTextView {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = alignment
        label.attributedText = attributedString
        containerStackView.addArrangedSubview(label)
        return self
    }
    
    /// Add vertical spacing
    @discardableResult
    func addSpacing(_ height: CGFloat) -> FormaTextView {
        let spacer = UIView()
        spacer.translatesAutoresizingMaskIntoConstraints = false
        spacer.heightAnchor.constraint(equalToConstant: height).isActive = true
        containerStackView.addArrangedSubview(spacer)
        return self
    }
    
    /// Set spacing between text elements
    @discardableResult
    func setSpacing(_ spacing: CGFloat) -> FormaTextView {
        containerStackView.spacing = spacing
        return self
    }
    
    /// Set alignment for all text
    @discardableResult
    func setAlignment(_ alignment: UIStackView.Alignment) -> FormaTextView {
        containerStackView.alignment = alignment
        return self
    }
    
    /// Clear all text
    func clear() {
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: - Helper Methods
    private func createLabel(
        text: String,
        font: UIFont,
        color: UIColor,
        alignment: NSTextAlignment
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = font
        label.textColor = color
        label.textAlignment = alignment
        label.numberOfLines = 0
        return label
    }
}

// MARK: - Advanced Builder Extensions

// MARK: - Advanced Builder Extensions

extension FormaTextView {
    
    /// Create title with highlighted words
    @discardableResult
    func addTitleWithHighlight(
        _ text: String,
        markWords: [(word: String, color: UIColor)],
        typography: Typography = .heading1,
        baseColor: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        return addText(
            text,
            markWords: markWords,
            typography: typography,
            baseColor: baseColor,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
    }
    
    /// Create heading with highlighted words
    @discardableResult
    func addHeadingWithHighlight(
        _ text: String,
        markWords: [(word: String, color: UIColor)],
        typography: Typography = .heading2,
        baseColor: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2
    ) -> FormaTextView {
        return addText(
            text,
            markWords: markWords,
            typography: typography,
            baseColor: baseColor,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
    }
    
    /// Create display text with highlighted words (hero moments)
    @discardableResult
    func addDisplayWithHighlight(
        _ text: String,
        markWords: [(word: String, color: UIColor)],
        typography: Typography = .displayMedium,
        baseColor: UIColor = .textPrimary,
        alignment: NSTextAlignment = .center,
        lineSpacing: CGFloat = 4
    ) -> FormaTextView {
        return addText(
            text,
            markWords: markWords,
            typography: typography,
            baseColor: baseColor,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
    }
    
    /// Create custom styled text with typography
    @discardableResult
    func addCustomText(
        _ text: String,
        typography: Typography,
        color: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2,
        markWords: [(word: String, color: UIColor)] = []
    ) -> FormaTextView {
        return addText(
            text,
            markWords: markWords,
            typography: typography,
            baseColor: color,
            alignment: alignment,
            lineSpacing: lineSpacing
        )
    }
    
    /// Legacy support - create custom text with font size/weight
    /// - Note: Prefer using Typography enum instead for consistency
    @available(*, deprecated, message: "Use addCustomText with Typography enum instead")
    @discardableResult
    func addCustomTextLegacy(
        _ text: String,
        fontSize: CGFloat,
        fontWeight: UIFont.Weight = .regular,
        color: UIColor = .textPrimary,
        alignment: NSTextAlignment = .left,
        lineSpacing: CGFloat = 2,
        markWords: [(word: String, color: UIColor)] = []
    ) -> FormaTextView {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = alignment
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = alignment
        
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        // Highlight marked words
        for (word, highlightColor) in markWords {
            let range = (text as NSString).range(of: word)
            if range.location != NSNotFound {
                attributedString.addAttribute(.foregroundColor, value: highlightColor, range: range)
            }
        }
        
        label.attributedText = attributedString
        containerStackView.addArrangedSubview(label)
        return self
    }
}
