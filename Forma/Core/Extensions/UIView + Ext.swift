import UIKit

extension UIView {
    func animateIn(delay: CGFloat = 1) {
        alpha = 0
        transform = CGAffineTransform(translationX: 0, y: 20)
        
        UIView.animate(
            withDuration: 0.4,
            delay: delay * 0.05,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.3
        ) {
            self.alpha = 1
            self.transform = .identity
        }
    }
}
