//
//  HomeViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//


import UIKit
import FirebaseAuth

// MARK: - HomeViewController

final class HomeViewController: BaseViewController {

    // MARK: - Data

    private var routines: [RoutineBlock] = []

    // MARK: - UI

    // Header
    private let headerView = HomeHeaderView()

    // Timeline scroll
    private let scrollView: UIScrollView = {
        let s = UIScrollView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.showsVerticalScrollIndicator = false
        s.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        return s
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Left timeline rail
    private let railView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let railLine: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 1, alpha: 0.10)
        v.layer.cornerRadius = 1
        return v
    }()

    // Progress dot on the rail (marks current time)
    private let progressDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.accent
        v.layer.cornerRadius = 7
        v.layer.shadowColor = UIColor.accent.cgColor
        v.layer.shadowOpacity = 0.8
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = .zero
        return v
    }()

    // Stack that holds all routine + task blocks
    private let timelineStack: UIStackView = {
        let s = UIStackView()
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .vertical
        s.spacing = 0
        return s
    }()

    // Tab bar background (custom, no tab bar controller)
    private let tabBar = HomeTabBar()

    // Floating add button
    private lazy var addButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor.accent
        b.tintColor = .black
        b.layer.cornerRadius = 30
        b.layer.shadowColor = UIColor.accent.cgColor
        b.layer.shadowOpacity = 0.5
        b.layer.shadowRadius = 12
        b.layer.shadowOffset = CGSize(width: 0, height: 4)
        let conf = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        b.setImage(UIImage(systemName: "plus", withConfiguration: conf), for: .normal)
        b.addTarget(self, action: #selector(addTapped), for: .touchUpInside)
        return b
    }()

    // Progress line that grows down the rail (accent color)
    private let progressLine: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor.accent
        v.layer.cornerRadius = 1
        return v
    }()

    private var progressLineHeightConstraint: NSLayoutConstraint?
    private var progressDotTopConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle

    override func setupViews() {
        super.setupViews()
        applyGradientBackground()
        setupLayout()
        loadRoutines()
        animateEntrance()
        scheduleProgressUpdate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Layout

    private func setupLayout() {
        // Rail line + progress overlay
        railView.addSubview(railLine)
        railView.addSubview(progressLine)
        railView.addSubview(progressDot)

        scrollView.addSubview(contentView)
        contentView.addSubview(railView)
        contentView.addSubview(timelineStack)

        view.addSubview(scrollView)
        view.addSubview(headerView)
        view.addSubview(tabBar)
        view.addSubview(addButton)

        headerView.translatesAutoresizingMaskIntoConstraints = false

        let progDotTop = progressDot.topAnchor.constraint(equalTo: railLine.topAnchor, constant: 0)
        self.progressDotTopConstraint = progDotTop

        let progLineH = progressLine.heightAnchor.constraint(equalToConstant: 0)
        self.progressLineHeightConstraint = progLineH

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            scrollView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // Rail — 48pt from left edge
            railView.topAnchor.constraint(equalTo: contentView.topAnchor),
            railView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            railView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            railView.widthAnchor.constraint(equalToConstant: 48),

            railLine.topAnchor.constraint(equalTo: railView.topAnchor, constant: 24),
            railLine.bottomAnchor.constraint(equalTo: railView.bottomAnchor),
            railLine.centerXAnchor.constraint(equalTo: railView.centerXAnchor),
            railLine.widthAnchor.constraint(equalToConstant: 2),

            progressLine.topAnchor.constraint(equalTo: railLine.topAnchor),
            progressLine.centerXAnchor.constraint(equalTo: railLine.centerXAnchor),
            progressLine.widthAnchor.constraint(equalToConstant: 2),
            progLineH,

            progressDot.centerXAnchor.constraint(equalTo: railLine.centerXAnchor),
            progressDot.widthAnchor.constraint(equalToConstant: 14),
            progressDot.heightAnchor.constraint(equalToConstant: 14),
            progDotTop,

            // Timeline stack to the right of rail
            timelineStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            timelineStack.leadingAnchor.constraint(equalTo: railView.trailingAnchor, constant: 8),
            timelineStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            timelineStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),

            // Tab bar
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: 90),

            // Add button centred above tab bar
            addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            addButton.widthAnchor.constraint(equalToConstant: 60),
            addButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }

    // MARK: - Data

    private func loadRoutines() {
        // TODO: inject via coordinator / use case
        // For now, use mock data so the layout is visible
        routines = RoutineBlock.allMocks
        buildTimeline()
    }

    // MARK: - Timeline builder

    private func buildTimeline() {
        timelineStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for routine in routines {
            // Routine header card
            let header = RoutineTimelineHeader(routine: routine)
            header.onTap = { [weak self] in self?.openEdit(routine: routine) }
            timelineStack.addArrangedSubview(header)

            // Task rows
            for task in routine.tasks {
                let row = TaskTimelineRow(task: task, accentColor: header.accentColor)
                timelineStack.addArrangedSubview(row)
            }

            // Spacer between routines
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.heightAnchor.constraint(equalToConstant: 28).isActive = true
            timelineStack.addArrangedSubview(spacer)
        }

        updateProgress(animated: false)
    }

    // MARK: - Progress

    private func scheduleProgressUpdate() {
        // Update every minute
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateProgress(animated: true)
        }
    }

    private func updateProgress(animated: Bool) {
        guard let firstRoutine = routines.first,
              let lastRoutine = routines.last else { return }

        let now = Date()
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
        guard let dayStart = fmt.date(from: firstRoutine.startTime),
              let dayEnd   = fmt.date(from: lastRoutine.endTime) else { return }

        let totalSpan = dayEnd.timeIntervalSince(dayStart)
        let elapsed   = now.timeIntervalSince(dayStart)
        let fraction  = max(0, min(CGFloat(elapsed / totalSpan), 1))

        // Full height of rail line is determined at layout time
        // We animate progressLine height and dot position
        let update = {
            self.view.layoutIfNeeded()
            let railH = self.railLine.bounds.height
            let dotY  = fraction * railH - 7  // centre dot
            self.progressLineHeightConstraint?.constant = fraction * railH
            self.progressDotTopConstraint?.constant = max(0, dotY)
            self.view.layoutIfNeeded()
        }

        if animated {
            UIView.animate(withDuration: 1.0, delay: 0,
                           usingSpringWithDamping: 0.9, initialSpringVelocity: 0,
                           animations: update)
        } else {
            update()
        }
    }

    // MARK: - Animations

    private func animateEntrance() {
        headerView.alpha = 0
        headerView.transform = CGAffineTransform(translationX: 0, y: -12)
        UIView.animate(withDuration: 0.5, delay: 0,
                       usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            self.headerView.alpha = 1
            self.headerView.transform = .identity
        }

        timelineStack.arrangedSubviews.enumerated().forEach { i, v in
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(withDuration: 0.55, delay: 0.06 * Double(i),
                           usingSpringWithDamping: 0.82, initialSpringVelocity: 0) {
                v.alpha = 1; v.transform = .identity
            }
        }

        addButton.transform = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.5, delay: 0.3,
                       usingSpringWithDamping: 0.65, initialSpringVelocity: 0.5) {
            self.addButton.transform = .identity
        }
    }

    // MARK: - Actions

    @objc private func addTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        UIView.animate(withDuration: 0.12, animations: {
            self.addButton.transform = CGAffineTransform(scaleX: 0.88, y: 0.88)
        }) { _ in
            UIView.animate(withDuration: 0.35, delay: 0,
                           usingSpringWithDamping: 0.55, initialSpringVelocity: 0.8) {
                self.addButton.transform = .identity
            }
        }
        // TODO: present add routine flow
    }

    private func openEdit(routine: RoutineBlock) {
        let vc = RoutineEditViewController(vm: .init(routine: routine))
        vc.onSave = { [weak self] updated in
            guard let self else { return }
            if let i = self.routines.firstIndex(where: { $0.id == updated.id }) {
                self.routines[i] = updated
                self.buildTimeline()
            }
        }
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
}

// MARK: - HomeHeaderView

final class HomeHeaderView: UIView {

    private let dayLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        l.textColor = UIColor(white: 1, alpha: 0.4)
        l.textTransform(to: Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1].uppercased())
        return l
    }()

    private let dateLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        let fmt = DateFormatter(); fmt.dateFormat = "MMMM d"
        l.text = fmt.string(from: Date())
        l.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        l.textColor = .white
        return l
    }()

    private let avatarButton: UIButton = {
        let b = UIButton(type: .system)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.backgroundColor = UIColor(white: 1, alpha: 0.12)
        b.layer.cornerRadius = 22
        b.layer.borderWidth = 1.5
        b.layer.borderColor = UIColor(white: 1, alpha: 0.15).cgColor
        b.clipsToBounds = true
        let conf = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        b.setImage(UIImage(systemName: "person.fill", withConfiguration: conf), for: .normal)
        b.tintColor = UIColor(white: 1, alpha: 0.6)
        return b
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(dayLabel)
        addSubview(dateLabel)
        addSubview(avatarButton)

        NSLayoutConstraint.activate([
            dayLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            dateLabel.topAnchor.constraint(equalTo: dayLabel.bottomAnchor, constant: 2),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),

            avatarButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            avatarButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            avatarButton.widthAnchor.constraint(equalToConstant: 44),
            avatarButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }
}

// MARK: - RoutineTimelineHeader

final class RoutineTimelineHeader: UIView {

    var onTap: (() -> Void)?
    let accentColor: UIColor

    private let routine: RoutineBlock

    private let iconContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 22
        v.clipsToBounds = true
        return v
    }()

    private let iconLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 24)
        l.textAlignment = .center
        return l
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
        l.textColor = .white
        l.numberOfLines = 1
        l.adjustsFontSizeToFitWidth = true
        l.minimumScaleFactor = 0.7
        return l
    }()

    private let timeLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.monospacedSystemFont(ofSize: 13, weight: .semibold)
        return l
    }()

    // Accent dot on the rail
    private let railDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 5
        return v
    }()

    init(routine: RoutineBlock) {
        self.routine = routine
        // Derive accent from icon position in palette
        let colors: [UIColor] = [
            UIColor(red: 1.00, green: 0.60, blue: 0.20, alpha: 1), // amber
            UIColor(red: 0.40, green: 0.55, blue: 1.00, alpha: 1), // blue
            UIColor(red: 0.70, green: 0.40, blue: 1.00, alpha: 1), // purple
            UIColor(red: 0.30, green: 0.90, blue: 0.60, alpha: 1), // green
        ]
        let hash = abs(routine.id.hashValue) % colors.count
        self.accentColor = colors[hash]
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        iconContainer.backgroundColor = accentColor.withAlphaComponent(0.18)
        railDot.backgroundColor = accentColor

        iconLabel.text = routine.icon.isEmpty ? "⚡" : routine.icon
        titleLabel.text = routine.title
        timeLabel.text = "\(formatTime(routine.startTime)) — \(formatTime(routine.endTime))"
        timeLabel.textColor = accentColor

        iconContainer.addSubview(iconLabel)
        addSubview(iconContainer)
        addSubview(titleLabel)
        addSubview(timeLabel)
        addSubview(railDot)

        // Tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapped))
        addGestureRecognizer(tap)

        NSLayoutConstraint.activate([
            // Rail dot sits at the far left (aligns with rail line in parent)
            railDot.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -34),
            railDot.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            railDot.widthAnchor.constraint(equalToConstant: 10),
            railDot.heightAnchor.constraint(equalToConstant: 10),

            iconContainer.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            iconContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 48),
            iconContainer.heightAnchor.constraint(equalToConstant: 48),

            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: iconContainer.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            timeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            timeLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            bottomAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: 16)
        ])
    }

    private func formatTime(_ str: String) -> String {
        let fmt = DateFormatter(); fmt.dateFormat = "HH:mm"
        guard let date = fmt.date(from: str) else { return str }
        let out = DateFormatter(); out.dateFormat = "HH:mm"
        return out.string(from: date)
    }

    @objc private func tapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIView.animate(withDuration: 0.1, animations: { self.transform = CGAffineTransform(scaleX: 0.97, y: 0.97) }) { _ in
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0) {
                self.transform = .identity
            }
        }
        onTap?()
    }
}

// MARK: - TaskTimelineRow

final class TaskTimelineRow: UIView {

    private let task: RoutineTask
    private let accentColor: UIColor

    private let card: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(white: 1, alpha: 0.05)
        v.layer.cornerRadius = 16
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(white: 1, alpha: 0.07).cgColor
        return v
    }()

    private let statusDot: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 2
        return v
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        l.textColor = .white
        return l
    }()

    private let descLabel: UILabel = {
        let l = UILabel()
        l.translatesAutoresizingMaskIntoConstraints = false
        l.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        l.textColor = UIColor(white: 1, alpha: 0.4)
        l.numberOfLines = 2
        return l
    }()

    init(task: RoutineTask, accentColor: UIColor) {
        self.task = task
        self.accentColor = accentColor
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        if task.isCompleted {
            statusDot.backgroundColor = accentColor.withAlphaComponent(0.3)
            statusDot.layer.borderColor = accentColor.withAlphaComponent(0.5).cgColor
            // Checkmark
            let conf = UIImage.SymbolConfiguration(pointSize: 9, weight: .bold)
            let check = UIImageView(image: UIImage(systemName: "checkmark", withConfiguration: conf))
            check.tintColor = accentColor
            check.translatesAutoresizingMaskIntoConstraints = false
            check.contentMode = .scaleAspectFit
            statusDot.addSubview(check)
            NSLayoutConstraint.activate([
                check.centerXAnchor.constraint(equalTo: statusDot.centerXAnchor),
                check.centerYAnchor.constraint(equalTo: statusDot.centerYAnchor)
            ])
            // Strikethrough title
            let attrs: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: UIColor(white: 1, alpha: 0.3)
            ]
            titleLabel.attributedText = NSAttributedString(string: task.title, attributes: attrs)
            descLabel.textColor = UIColor(white: 1, alpha: 0.2)
        } else {
            statusDot.backgroundColor = accentColor.withAlphaComponent(0.15)
            statusDot.layer.borderColor = accentColor.cgColor
            // Inner filled dot
            let inner = UIView()
            inner.translatesAutoresizingMaskIntoConstraints = false
            inner.backgroundColor = accentColor
            inner.layer.cornerRadius = 4
            statusDot.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.centerXAnchor.constraint(equalTo: statusDot.centerXAnchor),
                inner.centerYAnchor.constraint(equalTo: statusDot.centerYAnchor),
                inner.widthAnchor.constraint(equalToConstant: 8),
                inner.heightAnchor.constraint(equalToConstant: 8)
            ])
            titleLabel.text = task.title
        }

        descLabel.text = task.description

        card.addSubview(statusDot)
        card.addSubview(titleLabel)
        if !(task.description.isEmpty) {
            card.addSubview(descLabel)
        }

        addSubview(card)

        let hasDesc = !(task.description.isEmpty)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: topAnchor, constant: 6),
            card.leadingAnchor.constraint(equalTo: leadingAnchor),
            card.trailingAnchor.constraint(equalTo: trailingAnchor),
            card.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),

            statusDot.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            statusDot.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            statusDot.widthAnchor.constraint(equalToConstant: 16),
            statusDot.heightAnchor.constraint(equalToConstant: 16),

            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: hasDesc ? 14 : 0),
            titleLabel.leadingAnchor.constraint(equalTo: statusDot.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            hasDesc
                ? titleLabel.bottomAnchor.constraint(equalTo: descLabel.topAnchor, constant: -3)
                : titleLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
        ] + (hasDesc ? [
            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3),
            descLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
        ] : [
            card.heightAnchor.constraint(equalToConstant: 56)
        ]))
    }
}

// MARK: - HomeTabBar

final class HomeTabBar: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        // Frosted glass background
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        blur.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blur)

        let border = UIView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.backgroundColor = UIColor(white: 1, alpha: 0.08)
        addSubview(border)

        // Timeline tab (active)
        let timelineTab = makeTab(icon: "rectangle.3.group.fill", title: "TIMELINE", active: true)
        // Settings tab
        let settingsTab = makeTab(icon: "gearshape.fill", title: "SETTINGS", active: false)

        let stack = UIStackView(arrangedSubviews: [timelineTab, UIView(), settingsTab])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fill
        stack.alignment = .center
        addSubview(stack)

        NSLayoutConstraint.activate([
            blur.topAnchor.constraint(equalTo: topAnchor),
            blur.leadingAnchor.constraint(equalTo: leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: trailingAnchor),
            blur.bottomAnchor.constraint(equalTo: bottomAnchor),

            border.topAnchor.constraint(equalTo: topAnchor),
            border.leadingAnchor.constraint(equalTo: leadingAnchor),
            border.trailingAnchor.constraint(equalTo: trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),

            stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
        ])
    }

    private func makeTab(icon: String, title: String, active: Bool) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let conf = UIImage.SymbolConfiguration(pointSize: 20, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: icon, withConfiguration: conf))
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = active ? UIColor.accent : UIColor(white: 1, alpha: 0.3)
        iv.contentMode = .scaleAspectFit

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.monospacedSystemFont(ofSize: 9, weight: .bold)
        label.textColor = active ? UIColor.accent : UIColor(white: 1, alpha: 0.3)

        container.addSubview(iv)
        container.addSubview(label)

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: container.topAnchor),
            iv.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 24),
            iv.heightAnchor.constraint(equalToConstant: 24),

            label.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 4),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }
}

// MARK: - UILabel helper

private extension UILabel {
    func textTransform(to string: String) {
        text = string
    }
}
