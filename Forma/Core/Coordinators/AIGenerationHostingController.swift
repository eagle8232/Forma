import SwiftUI
import UIKit

final class AIGenerationHostingController<Content: View>: UIHostingController<Content> {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white.withAlphaComponent(0.25),
            .font: UIFont.systemFont(ofSize: 10, weight: .ultraLight)
        ]
        navigationController?.navigationBar.tintColor = .white.withAlphaComponent(0.25)
        
        let formaLabel = UILabel()
        formaLabel.text = "FORMA"
        formaLabel.font = UIFont.systemFont(ofSize: 10, weight: .ultraLight)
        formaLabel.textColor = UIColor.white.withAlphaComponent(0.18)
        formaLabel.sizeToFit()
        
        let thinkingLabel = UILabel()
        thinkingLabel.text = "THINKING"
        thinkingLabel.font = UIFont.systemFont(ofSize: 9, weight: .ultraLight)
        thinkingLabel.textColor = UIColor.white.withAlphaComponent(0.25)
        thinkingLabel.sizeToFit()
        
        let stackView = UIStackView(arrangedSubviews: [formaLabel, thinkingLabel])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        
        navigationItem.titleView = stackView
        navigationItem.hidesBackButton = true
    }
    
    override init(rootView: Content) {
        super.init(rootView: rootView)
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
