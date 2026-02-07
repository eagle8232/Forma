//
//  ViewController.swift
//  Forma
//
//  Created by Vusal Nuriyev on 1/21/26.
//


// MARK: - Word "Reimagined" will be changed every 3 secs to another word -

import UIKit

class ViewController: UIViewController {
    
    private var waveView: WavedLineView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundPrimary
        
        // Create wave view
        waveView = WavedLineView(frame: CGRect(
            x: 0,
            y: 200,
            width: view.bounds.width,
            height: 150
        ))
        
        view.addSubview(waveView)
        
        waveView.animateStroke()
    }
    
}
