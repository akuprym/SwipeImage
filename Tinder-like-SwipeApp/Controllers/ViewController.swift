//
//  ViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 25.01.24.
//

import UIKit

class ViewController: UIViewController {
    
    var currentPage = 1
    var currentPhotoIndex = 0
    let treshold: CGFloat = 75
    let photoIndexLimit = 1
    
    var cardView: UIView!
    var imageView: UIImageView!
    var thumbImageView: UIImageView!
    
    var results: [APIResponse] = []
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        cardView.addGestureRecognizer(panGesture)
        
        fetchPhotos()
    }
    
    // MARK: - Setup UI
    
    fileprivate func setupUI() {
        cardView = UIView(frame: CGRect(x: 0, y: 0, width: 380, height: 500))
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.backgroundColor = .white
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)
        
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 380),
            cardView.heightAnchor.constraint(equalToConstant: 500)
        ])
        
        imageView = UIImageView(frame: cardView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cardView.addSubview(imageView)
        
        thumbImageView = UIImageView()
        cardView.addSubview(thumbImageView)
        thumbImageView.frame = imageView.bounds
    }
    // MARK: - Swiping Gestures
    
    @objc fileprivate func handlePan(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .began:
            view?.subviews.forEach({ subview in
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
        
        let xFromCenter = cardView.center.x - view.center.x
        
        cardView.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        
        if xFromCenter > 0 {
            thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
            thumbImageView.tintColor = .green
        } else {
            thumbImageView.image = UIImage(systemName: "hand.thumbsdown.fill")
            thumbImageView.tintColor = .red
        }
        
        thumbImageView.alpha = abs(xFromCenter / view.center.x)
    }
    
    fileprivate func handleChangedState(_ gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: nil)
        
        setupThumbImageViewAnimation(translation)
        
        // rotation + conversion degrees to radians
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * CGFloat.pi / 180
        
        let rotationTransformation = CGAffineTransform(rotationAngle: angle)
        cardView.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func swipedLeft() {
        // Dislike
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.cardView.center = CGPoint(x: self.cardView.frame.origin.x - self.cardView.frame.width/2, y: self.view.center.y + self.treshold)
                self.thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
                self.thumbImageView.tintColor = .green
            }
            resetCard()
    }
    
    fileprivate func swipedRight() {
        // Like
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.cardView.center = CGPoint(x: self.view.frame.maxX + self.view.frame.width/2, y: self.imageView.center.y + self.treshold)
            }
            resetCard()
    }
    
    fileprivate func handleEndedState(_ gesture: UIPanGestureRecognizer) {
        
        cardView.center = CGPoint(x: view.center.x + gesture.translation(in: nil).x, y: view.center.y + gesture.translation(in: nil).y)
        
        if cardView.center.x < treshold {
            swipedLeft()
        } else if cardView.center.x > view.frame.width - treshold {
            swipedRight()
        } else {
            cardView.transform = .identity
            cardView.center = self.view.center
            thumbImageView.alpha = 0
        }
    }
    
    fileprivate func resetCard() {
                UIView.animate(withDuration: 0.5) {
                    self.currentPhotoIndex += 1
                    self.cardView.transform = .identity
                    self.cardView.center = self.view.center
                    self.thumbImageView.alpha = 0
                    self.downloadImage()
                }
    }
    
    // MARK: - Network Service
    
    fileprivate func fetchPhotos() {
            
            let unsplashAPIKey = "z-vsuLtEoiR6XfrHUqG2G-VAf-TxvMNr3Hfms4OBsNo"
            let urlString = "https://api.unsplash.com/photos/random?client_id=\(unsplashAPIKey)&count=2&page=\(currentPage)"
            
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data else { return }
                
                do {
                    let jsonResult = try JSONDecoder().decode([APIResponse].self, from: data)
                    DispatchQueue.main.async {
                        self.results = jsonResult
                        self.downloadImage()
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
    }
    
    fileprivate func downloadImage() {
        
        if currentPhotoIndex > photoIndexLimit {
            currentPage += 1
            currentPhotoIndex = 0
            fetchPhotos()
            
        } else {
            thumbImageView.alpha = 0
            let urlString = self.results[currentPhotoIndex].urls.regular
            guard let url = URL(string: urlString) else { return }
            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard error == nil,
                      let data = data,
                      let response = response as? HTTPURLResponse,
                      response.statusCode == 200 else { return }
                guard let image = UIImage(data: data) else { return }
                DispatchQueue.main.async {
                    self?.imageView.image = image
                }
            }
            dataTask.resume()
        }
    }
}
