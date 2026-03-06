//
//  HomeHeaderView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/27/26.
//

import UIKit

final class HomeHeaderView: UIView {
    
    private lazy var dateView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(DateManager.shared.getTodayDateString(isWeekday: true))
        tv.addHeading(DateManager.shared.getTodayDateString())
        tv.setAlignment(.leading)
        tv.setSpacing(2)
        return tv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        addSubview(dateView)
        
        NSLayoutConstraint.activate([
            dateView.topAnchor.constraint(equalTo: topAnchor),
            dateView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dateView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            dateView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
