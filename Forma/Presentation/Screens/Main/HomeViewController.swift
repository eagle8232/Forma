//
//  HomeViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 2/19/26.
//

import UIKit
import FirebaseAuth

final class HomeViewController: BaseViewController {
    
    private lazy var textView: FormaTextView = {
        let tv = FormaTextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        guard let user = Auth.auth().currentUser else { return }
        
        view.addSubview(textView)
        
        NSLayoutConstraint.activate([
            textView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            textView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        textView.addHeading(user.uid)
    }
}
