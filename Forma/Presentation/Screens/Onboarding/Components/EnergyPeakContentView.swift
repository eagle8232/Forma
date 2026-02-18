//
//  EnergyPeakContentView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/16/26.
//

import UIKit

protocol EnergyPeakContentViewDelegate: AnyObject {
    func energyPeakContentView(_ view: EnergyPeakContentView, didSelectWakeTime date: Date)
    func energyPeakContentView(_ view: EnergyPeakContentView, didSelectSleepTime date: Date)
}

final class EnergyPeakContentView: UIView {
    
    // MARK: - Properties
    
    weak var delegate: EnergyPeakContentViewDelegate?
    
    private lazy var wakeTimeCard: FormaTimePickerView = {
        let card = FormaTimePickerView(type: .wakeTime)
        card.delegate = self
        return card
    }()
    
    private lazy var sleepTimeCard: FormaTimePickerView = {
        let card = FormaTimePickerView(type: .sleepTime)
        card.delegate = self
        return card
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
    
    // MARK: - Public Methods
    
    func getWakeUpTime() -> Date? {
        return wakeTimeCard.selectedDate
    }
    
    func getSleepTime() -> Date? {
        return sleepTimeCard.selectedDate
    }
}

// MARK: - FormaTimePickerDelegate

extension EnergyPeakContentView: FormaTimePickerDelegate {
    
    func timePickerDidSelectTime(_ picker: FormaTimePickerView, date: Date) {
        if picker == wakeTimeCard {
            delegate?.energyPeakContentView(self, didSelectWakeTime: date)
        } else if picker == sleepTimeCard {
            delegate?.energyPeakContentView(self, didSelectSleepTime: date)
        }
    }
}

// MARK: - Setup
extension EnergyPeakContentView {
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        
        let cardsStackView = UIStackView(arrangedSubviews: [wakeTimeCard, sleepTimeCard])
        cardsStackView.translatesAutoresizingMaskIntoConstraints = false
        cardsStackView.axis = .horizontal
        cardsStackView.spacing = 16
        cardsStackView.distribution = .fillEqually
        cardsStackView.alignment = .fill
        
        addSubview(cardsStackView)
        
        NSLayoutConstraint.activate([
            cardsStackView.topAnchor.constraint(equalTo: topAnchor),
            cardsStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardsStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardsStackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cardsStackView.heightAnchor.constraint(equalToConstant: 200)
        ])
        
        cardsStackView.subviews.enumerated().forEach { index, view in
            view.animateIn(delay: CGFloat(index) * 3.5) // A bit longer
        }
    }
}
