//
//  CardView.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 21.04.24.
//

import UIKit

class CardView: UIView {
    
    var currentPage = 1
    var currentPhotoIndex = 0
    let treshold: CGFloat = 75
    let photoIndexLimit = 9
    
    var imageView = UIImageView(image: UIImage(named: "1"))
    var thumbImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
//        translatesAutoresizingMaskIntoConstraints = false
//               NSLayoutConstraint.activate([
//                self.centerXAnchor.constraint(equalTo: self.centerXAnchor),
//                self.centerYAnchor.constraint(equalTo: self.centerYAnchor),
//                   self.widthAnchor.constraint(equalToConstant: 380),
//                   self.heightAnchor.constraint(equalToConstant: 500)
//               ])
        layer.frame = CGRect(x: 0, y: 0, width: 380, height: 500)
        layer.cornerRadius = 10
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        backgroundColor = .white

        imageView = UIImageView(frame: self.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        
        imageView.addSubview(thumbImageView)
        bringSubviewToFront(thumbImageView)
        thumbImageView.frame = imageView.bounds
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(panGesture)
        
    }
    
    // MARK: - Swiping Gestures
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            self.subviews.forEach({ subview in
                subview.layer.removeAllAnimations()
            })
        case .changed:
            handleChangedState(gesture)
        case .ended:
            handleEndedState(gesture)
        default:
            ()
        }
    }
    
    fileprivate func setupThumbImageViewAnimation(_ translation: CGPoint) {
        
        let xFromCenter = imageView.center.x - self.center.x
        
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        
        if xFromCenter > 0 {
            thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
            thumbImageView.tintColor = .green
        } else {
            thumbImageView.image = UIImage(systemName: "hand.thumbsdown.fill")
            thumbImageView.tintColor = .red
        }
        
        thumbImageView.alpha = abs(xFromCenter / self.center.x)
    }
    
    fileprivate func handleChangedState(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: nil)
        
        setupThumbImageViewAnimation(translation)
        
        // rotation + conversion degrees to radians
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * CGFloat.pi / 180
        
        let rotationTransformation = CGAffineTransform(rotationAngle: angle)
        self.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func swipedLeft() {
        // Dislike
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.center = CGPoint(x: self.frame.origin.x - self.frame.width/2, y: self.center.y + self.treshold)
                self.thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
                self.thumbImageView.tintColor = .green
            }
//        self.removeFromSuperview()
//            resetCard()
    }
    
    fileprivate func swipedRight() {
        // Like
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.center = CGPoint(x: self.frame.maxX + self.frame.width/2, y: self.imageView.center.y + self.treshold)
            }
//        self.removeFromSuperview()
//            resetCard()
    }
    
    fileprivate func handleEndedState(_ gesture: UIPanGestureRecognizer) {
        
        self.center = CGPoint(x: self.center.x + gesture.translation(in: nil).x, y: self.center.y + gesture.translation(in: nil).y)
        
        if self.center.x < treshold {
            swipedLeft()
        } else if self.center.x > self.frame.width - treshold {
            swipedRight()
        } else {
            self.transform = .identity
            self.center = self.center
            thumbImageView.alpha = 0
        }
    }
    
    fileprivate func resetCard() {
                UIView.animate(withDuration: 0.5) {
                    self.currentPhotoIndex += 1
                    self.transform = .identity
//                    self.center = self.view.center
                    self.thumbImageView.alpha = 0
//                    self.downloadImage()
                }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

}


