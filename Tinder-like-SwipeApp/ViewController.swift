//
//  ViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 25.01.24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var card: UIView!
    
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        view.backgroundColor = .gray
        view.addSubview(card)
        view.addSubview(resetButton)
    }
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        let card = sender.view!
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        
        card.center = CGPoint(x: view.center.x + point.x, y: view.center.y + point.y)
        
        if xFromCenter > 0 {
            thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
            thumbImageView.tintColor = .green
        } else {
            thumbImageView.image = UIImage(systemName: "hand.thumbsdown.fill")
            thumbImageView.tintColor = .red
        }
        
        thumbImageView.alpha = abs(xFromCenter / view.center.x)
        
        if sender.state == UIGestureRecognizer.State.ended {
            
            if card.center.x < 75 {
                //dislike
                UIView.animate(withDuration: 0.3) {
                    card.center = CGPoint(x: self.view.frame.origin.x - card.frame.width/2, y: card.center.y + 75)
                    card.alpha = 0
                }
                return
            } else if card.center.x > view.frame.width - 75 {
                //like
                UIView.animate(withDuration: 0.3) {
                    card.center = CGPoint(x: self.view.frame.maxX + card.frame.width/2, y: card.center.y + 75)
                    card.alpha = 0
                }
                return
            }
            resetCard()
        }
    }
    
    @IBAction func reset(_ sender: UIButton) {
       resetCard()
    }
    
    func resetCard() {
        UIView.animate(withDuration: 0.2) {
            self.card.center = self.view.center
            self.thumbImageView.alpha = 0
            self.card.alpha = 1
        }
    }

}

