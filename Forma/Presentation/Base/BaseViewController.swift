//
//  BaseViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/10/26.
//

import UIKit

class BaseViewController: UIViewController {
    
    private lazy var loadingView: LoadingView = {
        let loadingView = LoadingView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        return loadingView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.backgroundPrimary
        setupViews()
    }
    
    func setupViews() {}
    
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
        visualEffectView.layer.cornerRadius = 20 // Round the blur background
        visualEffectView.clipsToBounds = true

        loadingView.insertSubview(visualEffectView, at: 0)

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: loadingView.topAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: -10),
            visualEffectView.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: 10),
            visualEffectView.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor)
        ])
        
        loadingView.startLoadingAnimation()
    }
    
    func hideLoadingView() {
        loadingView.stopLoadingAnimation()
        loadingView.removeFromSuperview()
    }
}
