import UIKit

class BaseViewController: UIViewController {

    private var gradientLayer: CAGradientLayer?
    private var glowLayer: CAGradientLayer?
    private lazy var loadingView: LoadingView = {
        let view = LoadingView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundPrimary
        setupViews()
    }

    func setupViews() {}

    func applyGradientBackground(
        colors: [UIColor] = [
            UIColor(red: 0.06, green: 0.06, blue: 0.08, alpha: 1),
            UIColor(red: 0.04, green: 0.05, blue: 0.07, alpha: 1)
        ],
        startPoint: CGPoint = CGPoint(x: 0.2, y: 0),
        endPoint: CGPoint = CGPoint(x: 0.8, y: 1),
        glowColor: UIColor? = UIColor.accent,
        glowOpacity: Float = 0.40
    ) {
        view.backgroundColor = colors.last ?? .black

        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.frame = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient

        if let glow = glowColor, glowOpacity > 0 {
            let glowL = CAGradientLayer()
            glowL.type = .radial
            glowL.colors = [
                glow.withAlphaComponent(CGFloat(glowOpacity)).cgColor,
                UIColor.clear.cgColor
            ]
            glowL.startPoint = CGPoint(x: 0.5, y: 0)
            glowL.endPoint = CGPoint(x: 1, y: 1)
            glowL.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.45)
            view.layer.insertSublayer(glowL, at: 1)
            glowLayer = glowL
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
        glowLayer?.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.55)
    }

    func showLoadingView() {
        view.insertSubview(loadingView, at: view.subviews.count)
        
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loadingView.widthAnchor.constraint(equalToConstant: 100),
            loadingView.heightAnchor.constraint(equalToConstant: 100)
        ])

        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.layer.cornerRadius = 20
        visualEffectView.clipsToBounds = true
        loadingView.insertSubview(visualEffectView, at: 0)

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: loadingView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: -10),
            visualEffectView.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: 10),
            visualEffectView.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor)
        ])

        view.isUserInteractionEnabled = false
        loadingView.startLoadingAnimation()
    }

    func hideLoadingView() {
        view.isUserInteractionEnabled = true
        loadingView.stopLoadingAnimation()
        loadingView.removeFromSuperview()
    }

    func animateIn(_ views: [UIView], delay: Double = 0.08) {
        views.enumerated().forEach { index, view in
            view.alpha = 0
            view.transform = CGAffineTransform(translationX: 0, y: 20)
            UIView.animate(
                withDuration: 0.4,
                delay: Double(index) * delay,
                usingSpringWithDamping: 0.8,
                initialSpringVelocity: 0.3
            ) {
                view.alpha = 1
                view.transform = .identity
            }
        }
    }
}
