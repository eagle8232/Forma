//
//  TestViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/23/26.
//

import UIKit

final class TestViewController: BaseViewController {
    
    private lazy var timelineScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = .clear
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
    
    private lazy var timelineContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var verticalTimelineView: VerticalTimelineView = {
        let view = VerticalTimelineView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // - For testing timeline view
    lazy var professionGridView: ProfessionalLifeGridView = {
        let view = ProfessionalLifeGridView()
        view.delegate = self
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        setupLayouts()
        
    }
    
}

extension TestViewController: ProfessionalLifeGridViewDelegate {
    func professionalLifeGridView(_ view: ProfessionalLifeGridView, didSelect role: ProfessionRole) {
        print(role)
    }
}

// MARK: - Layout
extension TestViewController {
    private func setupLayouts() {
        
        timelineScrollView.addSubview(timelineContentView)
        view.addSubview(timelineScrollView)
        
        timelineContentView.addSubview(verticalTimelineView)
        timelineContentView.addSubview(professionGridView)
        
        NSLayoutConstraint.activate([
            
            timelineScrollView.topAnchor.constraint(equalTo: view.topAnchor),
            timelineScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timelineScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timelineScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            timelineContentView.topAnchor.constraint(equalTo: timelineScrollView.topAnchor),
            timelineContentView.leadingAnchor.constraint(equalTo: timelineScrollView.leadingAnchor),
            timelineContentView.trailingAnchor.constraint(equalTo: timelineScrollView.trailingAnchor),
            timelineContentView.bottomAnchor.constraint(equalTo: timelineScrollView.bottomAnchor),
            timelineContentView.widthAnchor.constraint(equalTo: timelineScrollView.widthAnchor),
            
            professionGridView.topAnchor.constraint(equalTo: timelineContentView.topAnchor, constant: 8),
            professionGridView.leadingAnchor.constraint(equalTo: verticalTimelineView.trailingAnchor, constant: 15),
            professionGridView.trailingAnchor.constraint(equalTo: timelineContentView.trailingAnchor, constant: -16),
            professionGridView.bottomAnchor.constraint(equalTo: timelineContentView.bottomAnchor, constant: -8),
            
            verticalTimelineView.topAnchor.constraint(equalTo: timelineContentView.topAnchor),
            verticalTimelineView.leadingAnchor.constraint(equalTo: timelineContentView.leadingAnchor),
            verticalTimelineView.widthAnchor.constraint(equalToConstant: 35),
            verticalTimelineView.heightAnchor.constraint(equalTo: professionGridView.heightAnchor),
        ])
    }
}
