//
//  ViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 1/21/26.
//

import UIKit

class ViewController: UIViewController {
    
    private lazy var sampleText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "This is sample text!"
        label.font = UIFont.textFont(weight: .footnote, size: 15, italic: true)
        label.textColor = .textPrimary
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        view.addSubview(sampleText)
        
        NSLayoutConstraint.activate([
            sampleText.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sampleText.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }


}

