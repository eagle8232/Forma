//
//  SignUpViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import UIKit
import Combine

final class AuthViewController: BaseViewController {

    // MARK: - Properties

    weak var coordinator: AuthCoordinator?
    var viewModel = AuthViewModel()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Scroll

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.showsVerticalScrollIndicator = false
        sv.alwaysBounceVertical = true
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Logo

    private let logoShadowView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .clear
        v.layer.shadowColor = UIColor.accent.cgColor
        v.layer.shadowOpacity = 0.45
        v.layer.shadowRadius = 24
        v.layer.shadowOffset = CGSize(width: 0, height: 8)
        return v
    }()

    private let logoContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.layer.cornerRadius = 20
        v.clipsToBounds = true
        return v
    }()

    private let logoGradient: CAGradientLayer = {
        let l = CAGradientLayer()
        l.colors = [
            UIColor(red: 0.55, green: 0.40, blue: 1.00, alpha: 1).cgColor,
            UIColor(red: 0.30, green: 0.55, blue: 1.00, alpha: 1).cgColor
        ]
        l.startPoint = CGPoint(x: 0, y: 0)
        l.endPoint = CGPoint(x: 1, y: 1)
        l.cornerRadius = 20
        return l
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .semibold)
        iv.image = UIImage(systemName: "f.cursive", withConfiguration: config)
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    // MARK: - Text (FormaTextView)

    private let wordmarkTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption("F  O  R  M  A", color: .accent, alignment: .center)
        return tv
    }()

    private let headlineTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCustomText(
            "Craft your\nperfect day",
            typography: .heading1,
            color: .white,
            alignment: .center,
            lineSpacing: 6
        )
        return tv
    }()

    private let subtitleTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addBody(
            "Sign in to continue your journey",
            color: UIColor(white: 1, alpha: 0.45),
            alignment: .center
        )
        return tv
    }()

    private let footerTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.addCaption(
            "By continuing, you agree to our Terms of Service and Privacy Policy",
            color: UIColor(white: 1, alpha: 0.22),
            alignment: .center
        )
        return tv
    }()

    // MARK: - Divider

    private let dividerStack: UIStackView = {
        let leftLine = UIView()
        leftLine.translatesAutoresizingMaskIntoConstraints = false
        leftLine.backgroundColor = UIColor(white: 1, alpha: 0.1)
        leftLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let label = UILabel()
        label.text = "continue with"
        label.font = UIFont.systemFont(ofSize: 11, weight: .medium)
        label.textColor = UIColor(white: 1, alpha: 0.28)

        let rightLine = UIView()
        rightLine.translatesAutoresizingMaskIntoConstraints = false
        rightLine.backgroundColor = UIColor(white: 1, alpha: 0.1)
        rightLine.heightAnchor.constraint(equalToConstant: 1).isActive = true

        let stack = UIStackView(arrangedSubviews: [leftLine, label, rightLine])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .center
        leftLine.widthAnchor.constraint(equalTo: rightLine.widthAnchor).isActive = true
        return stack
    }()

    // MARK: - Buttons (FormaButton)

    private lazy var appleButton: FormaButton = {
        let btn = FormaButton(configuration: .init(
            title: "Apple",
            icon: UIImage(systemName: "apple.logo"),
            iconPosition: .leading,
            style: .rectangle,
            backgroundColor: UIColor(white: 1, alpha: 0.07),
            titleColor: .white,
            borderColor: UIColor(white: 1, alpha: 0.12),
            borderWidth: 1,
            cornerRadius: 16,
            contentPadding: UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20),
            iconSize: 18,
            iconSpacing: 8
        ))
        btn.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var googleButton: FormaButton = {
        let btn = FormaButton(configuration: .init(
            title: "Google",
            icon: UIImage(systemName: "g.circle.fill"),
            iconPosition: .leading,
            style: .rectangle,
            backgroundColor: UIColor(white: 1, alpha: 0.07),
            titleColor: .white,
            borderColor: UIColor(white: 1, alpha: 0.12),
            borderWidth: 1,
            cornerRadius: 16,
            contentPadding: UIEdgeInsets(top: 18, left: 20, bottom: 18, right: 20),
            iconSize: 18,
            iconSpacing: 8
        ))
        btn.addTarget(self, action: #selector(googleTapped), for: .touchUpInside)
        return btn
    }()

    private lazy var buttonStack: UIStackView = {
        let s = UIStackView(arrangedSubviews: [appleButton, googleButton])
        s.translatesAutoresizingMaskIntoConstraints = false
        s.axis = .horizontal
        s.spacing = 12
        s.distribution = .fillEqually
        return s
    }()

    // MARK: - Error

    private let errorContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 0.12)
        v.layer.cornerRadius = 12
        v.layer.borderWidth = 1
        v.layer.borderColor = UIColor(red: 1.0, green: 0.2, blue: 0.3, alpha: 0.3).cgColor
        v.alpha = 0
        return v
    }()

    private let errorTextView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoGradient.frame = logoContainer.bounds
    }

    override func setupViews() {
        super.setupViews()
        applyGradientBackground()
        setupLayout()
        bindViewModel()
        animateIn()
    }

    // MARK: - Setup

    // MARK: - Entry Animation

    private func animateIn() {
        let views: [UIView] = [
            logoShadowView, wordmarkTextView, headlineTextView,
            subtitleTextView, dividerStack, buttonStack, footerTextView
        ]
        views.forEach {
            $0.alpha = 0
            $0.transform = CGAffineTransform(translationX: 0, y: 28)
        }
        animateIn(views)
    }

    // MARK: - Bindings

    private func bindViewModel() {
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.showError($0) }
            .store(in: &cancellables)

        viewModel.$isAppleLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.appleButton.setLoading($0) }
            .store(in: &cancellables)

        viewModel.$isGoogleLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.googleButton.setLoading($0) }
            .store(in: &cancellables)
    }

    // MARK: - Error Display

    private func showError(_ message: String?) {
        // Silently ignore cancelled — user tapped the native sheet's Cancel
        guard let message else {
            UIView.animate(withDuration: 0.2) { self.errorContainer.alpha = 0 }
            return
        }

        errorTextView.clear()
        errorTextView.addCaption(
            message,
            color: UIColor(red: 1.0, green: 0.45, blue: 0.45, alpha: 1),
            alignment: .center
        )

        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.5
        ) {
            self.errorContainer.alpha = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) { [weak self] in
            UIView.animate(withDuration: 0.3) { self?.errorContainer.alpha = 0 }
        }
    }

    // MARK: - Actions

    @objc private func appleTapped() {
        Task {
            do {
                try await viewModel.signInWithApple()
                await MainActor.run { coordinator?.didCompleteSignIn() }
            } catch let error as AuthError where error == .cancelled {
                // User dismissed — do nothing
            } catch let error as AuthError {
                viewModel.errorMessage = error.errorDescription
            } catch {
                viewModel.errorMessage = "Apple Sign In failed. Please try again."
            }
        }
    }

    @objc private func googleTapped() {
        Task {
            do {
                try await viewModel.requestAuthWithGoogle()
                await MainActor.run { coordinator?.didCompleteSignIn() }
            } catch let error as AuthError where error == .cancelled {
                // User dismissed — do nothing
            } catch let error as AuthError {
                viewModel.errorMessage = error.errorDescription
            } catch {
                viewModel.errorMessage = "Google Sign In failed. Please try again."
            }
        }
    }
}

// MARK: - Setup
extension AuthViewController {
    private func setupLayout() {
        logoContainer.layer.insertSublayer(logoGradient, at: 0)
        logoContainer.addSubview(logoImageView)
        logoShadowView.addSubview(logoContainer)
        errorContainer.addSubview(errorTextView)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        [logoShadowView, wordmarkTextView, headlineTextView,
         subtitleTextView, dividerStack, buttonStack,
         errorContainer, footerTextView].forEach { contentView.addSubview($0) }

        let logoSize: CGFloat = 72

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            logoShadowView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 100),
            logoShadowView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoShadowView.widthAnchor.constraint(equalToConstant: logoSize),
            logoShadowView.heightAnchor.constraint(equalToConstant: logoSize),

            logoContainer.topAnchor.constraint(equalTo: logoShadowView.topAnchor),
            logoContainer.leadingAnchor.constraint(equalTo: logoShadowView.leadingAnchor),
            logoContainer.trailingAnchor.constraint(equalTo: logoShadowView.trailingAnchor),
            logoContainer.bottomAnchor.constraint(equalTo: logoShadowView.bottomAnchor),

            logoImageView.centerXAnchor.constraint(equalTo: logoContainer.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: logoContainer.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 32),
            logoImageView.heightAnchor.constraint(equalToConstant: 32),

            wordmarkTextView.topAnchor.constraint(equalTo: logoShadowView.bottomAnchor, constant: 20),
            wordmarkTextView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            headlineTextView.topAnchor.constraint(equalTo: wordmarkTextView.bottomAnchor, constant: 40),
            headlineTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            headlineTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            subtitleTextView.topAnchor.constraint(equalTo: headlineTextView.bottomAnchor, constant: 14),
            subtitleTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            subtitleTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            dividerStack.topAnchor.constraint(equalTo: subtitleTextView.bottomAnchor, constant: 52),
            dividerStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            dividerStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            buttonStack.topAnchor.constraint(equalTo: dividerStack.bottomAnchor, constant: 20),
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            errorContainer.topAnchor.constraint(equalTo: buttonStack.bottomAnchor, constant: 16),
            errorContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            errorContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),

            errorTextView.topAnchor.constraint(equalTo: errorContainer.topAnchor, constant: 12),
            errorTextView.leadingAnchor.constraint(equalTo: errorContainer.leadingAnchor, constant: 16),
            errorTextView.trailingAnchor.constraint(equalTo: errorContainer.trailingAnchor, constant: -16),
            errorTextView.bottomAnchor.constraint(equalTo: errorContainer.bottomAnchor, constant: -12),

            footerTextView.topAnchor.constraint(equalTo: errorContainer.bottomAnchor, constant: 36),
            footerTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 48),
            footerTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -48),
            footerTextView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -48)
        ])
    }

}
