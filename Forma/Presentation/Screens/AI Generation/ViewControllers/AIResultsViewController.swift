//
//  AIResultsView.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/18/26.
//

//
//  AIResultsViewController.swift
//  Forma
//

import UIKit
import Combine

final class AIResultsViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AIGenerationCoordinator?
    private var viewModel: AIResultsViewModel!
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        sv.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130, right: 0)
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Header Text

    private let eyebrowTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(
            "AI · GENERATED FOR YOU",
            typography: .monospacedMedium,
            color: UIColor.accent.withAlphaComponent(0.8),
            alignment: .left
        )
        return tv
    }()

    private let titleTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.setAlignment(.leading)
        tv.addCustomText(
            "Your\nPersonalized\nRoutine",
            typography: .heading1,
            color: .white,
            alignment: .left,
            lineSpacing: 4
        )
        return tv
    }()

    // MARK: - Stats Card (populated in setupViews)

    private var statsCard: AIResultsStatsCard?

    // MARK: - Section Label

    private let sectionTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(
            "YOUR BLOCKS",
            color: UIColor(white: 1, alpha: 0.3),
            alignment: .left
        )
        return tv
    }()

    // MARK: - Routines Stack

    private let routinesStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 14
        return s
    }()

    // MARK: - CTA

    private let ctaContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let ctaGradientLayer: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [
            UIColor.clear.cgColor,
            UIColor(red: 0.05, green: 0.05, blue: 0.07, alpha: 0.96).cgColor,
            UIColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1).cgColor
        ]
        l.locations = [0, 0.4, 1]
        l.startPoint = CGPoint(x: 0.5, y: 0)
        l.endPoint = CGPoint(x: 0.5, y: 1)
        return l
    }()

    private lazy var startButton: FormaButton = {
        let btn = FormaButton.primary(title: "✦  Start Your Flow")
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        return btn
    }()

    private let startButtonGlow: CALayer = {
        let l = CALayer()
        l.backgroundColor = UIColor.clear.cgColor
        l.shadowColor = UIColor.accent.cgColor
        l.shadowOpacity = 0.6
        l.shadowRadius = 18
        l.shadowOffset = .zero
        l.cornerRadius = 30
        return l
    }()

    // MARK: - Configure

    func configure(with userPreferences: UserPreferences, routines: [RoutineBlock]) {
        self.viewModel = AIResultsViewModel(userPreferences: userPreferences, routines: routines)
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        guard viewModel != nil else {
            fatalError("Call configure(with:routines:) before presenting.")
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ctaGradientLayer.frame = ctaContainer.bounds
        startButtonGlow.frame = startButton.bounds
    }

    override func setupViews() {
        super.setupViews()
        navigationItem.hidesBackButton = true
        applyGradientBackground()
        buildStatsCard()
        setupLayout()
        bindViewModel()
        startGlowPulse()
    }

    // MARK: - Stats Card Builder

    private func buildStatsCard() {
        let stats: [AIResultsStatsCard.Stat] = [
            .init(value: "\(viewModel.routines.count)", label: "Routines"),
            .init(value: viewModel.getTotalDuration(), label: "Duration"),
            .init(value: "\(viewModel.routines.flatMap { $0.tasks }.count)", label: "Tasks")
        ]
        let card = AIResultsStatsCard(stats: stats)
        self.statsCard = card
    }

   

    // MARK: - Routines

    private func reloadRoutines() {
        routinesStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        viewModel.routines.enumerated().forEach { index, routine in
            let cell = AIResultsRoutineCell(routine: routine, accentColor: paletteColor(for: index))

            cell.onEdit = { [weak self] in
                self?.viewModel.selectRoutineForEdit(routine)
            }

            cell.onDelete = { [weak self] in
                self?.confirmDelete(cell: cell, routine: routine)
            }

            routinesStack.addArrangedSubview(cell)
            cell.animateIn(delay: 0.3 + 0.08 * Double(index))
        }
    }

    private func confirmDelete(cell: AIResultsRoutineCell, routine: RoutineBlock) {
        let alert = UIAlertController(
            title: "Delete Routine",
            message: "Remove \"\(routine.title)\"?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            cell.animateOut {
                self?.viewModel.deleteRoutine(routine)
            }
        })
        present(alert, animated: true)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.$routines
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.buildStatsCard()
                self?.reloadRoutines()
            }
            .store(in: &cancellables)

        viewModel.$selectedRoutineForEdit
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in self?.showEditSheet(for: $0) }
            .store(in: &cancellables)
    }

    // MARK: - Animations

    private func startGlowPulse() {
        let pulse = CABasicAnimation(keyPath: "shadowOpacity")
        pulse.fromValue = 0.45
        pulse.toValue = 0.85
        pulse.duration = 1.8
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        startButtonGlow.add(pulse, forKey: "glowPulse")
    }

    // MARK: - Helpers

    private func paletteColor(for index: Int) -> UIColor {
        let palette: [UIColor] = [
            .accent,
            UIColor(red: 0.3, green: 0.82, blue: 0.62, alpha: 1),
            UIColor(red: 0.95, green: 0.52, blue: 0.32, alpha: 1),
            UIColor(red: 0.42, green: 0.62, blue: 1.00, alpha: 1),
            UIColor(red: 0.92, green: 0.35, blue: 0.52, alpha: 1)
        ]
        return palette[index % palette.count]
    }

    // MARK: - Actions

    @objc private func startTapped() {
        SoundManager.shared.playSound(.buttonTap)
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        coordinator?.didTapStartButton(with: viewModel.userPreferences, routines: viewModel.routines)
    }

    private func showEditSheet(for routine: RoutineBlock) {
        let editVC = RoutineEditViewController(vm: .init(routine: routine))
        editVC.onSave = { [weak self] updated in self?.viewModel.updateRoutine(updated) }
        let nav = UINavigationController(rootViewController: editVC)
        nav.modalPresentationStyle = .pageSheet
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        present(nav, animated: true)
    }
}


// MARK: - Layout
extension AIResultsViewController {
    private func setupLayout() {
        guard let statsCard else { return }
        
        // CTA layer + button
        ctaContainer.layer.insertSublayer(ctaGradientLayer, at: 0)
        startButton.layer.insertSublayer(startButtonGlow, at: 0)
        ctaContainer.addSubview(startButton)
        
        // Scroll
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [eyebrowTextView, titleTextView, statsCard,
         sectionTextView, routinesStack].forEach { contentView.addSubview($0) }
        
        // Floating CTA
        view.addSubview(ctaContainer)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Eyebrow
            eyebrowTextView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            eyebrowTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Title
            titleTextView.topAnchor.constraint(equalTo: eyebrowTextView.bottomAnchor, constant: 12),
            titleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            titleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            
            // Stats card
            statsCard.topAnchor.constraint(equalTo: titleTextView.bottomAnchor, constant: 28),
            statsCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            statsCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            statsCard.heightAnchor.constraint(equalToConstant: 100),
            
            // Section label
            sectionTextView.topAnchor.constraint(equalTo: statsCard.bottomAnchor, constant: 36),
            sectionTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            
            // Routines
            routinesStack.topAnchor.constraint(equalTo: sectionTextView.bottomAnchor, constant: 12),
            routinesStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            routinesStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            routinesStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            // CTA
            ctaContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ctaContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ctaContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ctaContainer.heightAnchor.constraint(equalToConstant: 130),
            
            startButton.leadingAnchor.constraint(equalTo: ctaContainer.leadingAnchor, constant: 24),
            startButton.trailingAnchor.constraint(equalTo: ctaContainer.trailingAnchor, constant: -24),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            startButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        animateIn([eyebrowTextView, statsCard, titleTextView, routinesStack, ctaContainer, startButton])
    }
}
