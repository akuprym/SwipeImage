//
//  ViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 25.01.24.
//

import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var card: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        view.addSubview(card)
        view.backgroundColor = .blue
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        // how far you moved the cursor
        let point = sender.translation(in: view)
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
    }
    
}
