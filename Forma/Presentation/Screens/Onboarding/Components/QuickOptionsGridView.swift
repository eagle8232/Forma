//
//  QuickOptionsGridView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/17/26.
//

import UIKit

enum QuickTimeOption: String, CaseIterable {
    case eight    = "8:00 AM"
    case nine     = "9:00 AM"
    case ten      = "10:00 AM"
    case flexible = "Flexible / Irregular"
    
    var hour: Int? {
        switch self {
        case .eight:    return 8
        case .nine:     return 9
        case .ten:      return 10
        case .flexible: return nil
        }
    }
    
    var date: Date? {
        guard let hour = hour else { return nil }
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.timeZone = .autoupdatingCurrent
        components.hour = hour
        components.minute = 0
        return Calendar.current.date(from: components)
    }
}

protocol QuickOptionsGridViewDelegate: AnyObject {
    func quickOptionsGridView(_ view: QuickOptionsGridView, didSelect option: QuickTimeOption)
}

final class QuickOptionsGridView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: QuickOptionsGridViewDelegate?
    private(set) var selectedOption: QuickTimeOption?
    private var buttons: [SelectableOptionButton] = []
    
    // MARK: - UI Components
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Quick Select"
        label.font = .typography(.label)
        label.textColor = .textSecondary
        return label
    }()
    
    private lazy var gridStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
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
    
    // MARK: - Setup
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleLabel)
        addSubview(gridStackView)
        
        setupGrid()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            gridStackView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            gridStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            gridStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            gridStackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func setupGrid() {
        // Row 1: 8 AM and 9 AM
        let row1 = createRow(left: .eight, right: .nine)
        
        // Row 2: 10 AM and Flexible
        let row2 = createRow(left: .ten, right: .flexible)
        
        gridStackView.addArrangedSubview(row1)
        gridStackView.addArrangedSubview(row2)
    }
    
    private func createRow(left: QuickTimeOption, right: QuickTimeOption) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        row.alignment = .fill
        
        let leftButton  = createButton(for: left)
        let rightButton = createButton(for: right)
        
        row.addArrangedSubview(leftButton)
        row.addArrangedSubview(rightButton)
        
        NSLayoutConstraint.activate([
            leftButton.heightAnchor.constraint(equalToConstant: 56),
            rightButton.heightAnchor.constraint(equalToConstant: 56)
        ])
        
        return row
    }

    private func createButton(for option: QuickTimeOption) -> SelectableOptionButton {
        let button = SelectableOptionButton(title: option.rawValue)
        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        button.tag = QuickTimeOption.allCases.firstIndex(of: option) ?? 0
        buttons.append(button)
        return button
    }

    // MARK: - Public Methods
    
    func selectOption(_ option: QuickTimeOption, animated: Bool = true) {
        selectedOption = option
        
        let update = {
            self.buttons.forEach { button in
                if button.optionTitle == option.rawValue {
                    button.applySelectedStyle()
                } else {
                    button.applyUnselectedStyle()
                }
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.2) { update() }
        } else {
            update()
        }
    }
    
    func clearSelection() {
        selectedOption = nil
        UIView.animate(withDuration: 0.2) {
            self.buttons.forEach { $0.applyUnselectedStyle() }
        }
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: SelectableOptionButton) {
        SoundManager.shared.playSound(.buttonTap)
        
        let option = QuickTimeOption.allCases[sender.tag]
        
        sender.animateTap {
            self.selectOption(option)
            self.delegate?.quickOptionsGridView(self, didSelect: option)
        }
        
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
}
