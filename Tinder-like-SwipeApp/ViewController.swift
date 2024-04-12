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
    var isLoading = false
    
    var cardView: UIView!
    var imageView: UIImageView!
    var thumbImageView: UIImageView!
    var likeButton: UIBarButtonItem!
    
    var results: [APIResponse] = []
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
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
        loadNextSetOfPhotos()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        cardView.addGestureRecognizer(panGesture)
        thumbImageView = UIImageView()
        cardView.addSubview(thumbImageView)
        thumbImageView.frame = imageView.bounds
        
        loadNextSetOfPhotos()
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
        if currentPhotoIndex < 9 {
            currentPhotoIndex += 1
            imageView.image = images[currentPhotoIndex]
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.cardView.center = CGPoint(x: self.cardView.frame.origin.x - self.cardView.frame.width/2, y: self.view.center.y + self.treshold)
                self.thumbImageView.image = UIImage(systemName: "hand.thumbsup.fill")
                self.thumbImageView.tintColor = .green
                self.resetImageViewPosition()
            }
        } else {
            loadNextSetOfPhotos()
            currentPhotoIndex = 0
        }
    }
    
    fileprivate func swipedRight() {
        // Like
        if currentPhotoIndex < 9 {
            imageView.image = images[currentPhotoIndex]
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.cardView.center = CGPoint(x: self.view.frame.maxX + self.view.frame.width/2, y: self.imageView.center.y + self.treshold)
                self.images.append(self.imageView.image!)
                self.currentPhotoIndex += 1
                self.resetImageViewPosition()
            }
        }  else {
            loadNextSetOfPhotos()
            currentPhotoIndex = 0
        }
    }
    
    fileprivate func handleEndedState(_ gesture: UIPanGestureRecognizer) {
        
        cardView.center = CGPoint(x: view.center.x + gesture.translation(in: nil).x, y: view.center.y + gesture.translation(in: nil).y)
        
        if cardView.center.x < treshold {
            swipedLeft()
        } else if cardView.center.x > view.frame.width - treshold {
            swipedRight()
        } else {
            resetImageViewPosition()
        }
    }
    
    func resetImageViewPosition() {
         UIView.animate(withDuration: 0.3) {
             self.imageView.center = self.view.center
         }
     }
    
    
//    fileprivate func resetCard() {
//        UIView.animate(withDuration: 0.5) {
//            self.currentPhotoIndex += 1
//            self.cardView.transform = .identity
//            self.cardView.center = self.view.center
////            self.downloadImage()
//        }
//    }
    
    // MARK: - Network Service
    
    fileprivate func loadNextSetOfPhotos() {
        
        guard !isLoading else { return }
                isLoading = true
        
        let unsplashAPIKey = "FrxT9u6XQRE_HVqjS9MhfYTH5LN0SsnhIp8VheooyRs"
        let urlString = "https://api.unsplash.com/photos/random?client_id=\(unsplashAPIKey)&count=10&page=\(currentPage)"

        guard let url = URL(string: urlString) else { return }
               
               let task = URLSession.shared.dataTask(with: url) { [weak self] (data, _, error) in
                   guard let self = self else { return }
                   defer { self.isLoading = false }
                   
                   if let error = error {
                       print("Error fetching images: \(error)")
                       return
                   }
                   
                   guard let data = data else { return }
                   
            do {
                let jsonResult = try JSONDecoder().decode([APIResponse].self, from: data)
                let imageUrls = jsonResult.compactMap { URL(string: $0.urls.regular) }
                               self.images = imageUrls.compactMap { try? Data(contentsOf: $0) }.compactMap { UIImage(data: $0) }
                               
                               DispatchQueue.main.async {
                                   self.imageView.image = self.images.first
                               }
//                DispatchQueue.main.async {
//                    self.results = jsonResult
//                    self.downloadImage()
//                                   
//                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    
//    fileprivate func downloadImage() {
//        
//        if currentPhotoIndex > 9 {
//            currentPage += 1
//            currentPhotoIndex = 0
//            fetchPhotos()
//        } else {
//            thumbImageView.alpha = 0
//            let urlString = self.results[currentPhotoIndex].urls.regular
//            guard let url = URL(string: urlString) else { return }
//            let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
//            let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//                guard error == nil,
//                      let data = data,
//                      let response = response as? HTTPURLResponse,
//                      response.statusCode == 200 else { return }
//                guard let image = UIImage(data: data) else { return }
//                DispatchQueue.main.async {
//                    self?.imageView.image = image
//                    self?.images = image.compactMap { try? Data(contentsOf: $0) }.compactMap { UIImage(data: $0) }
//                }
//            }
//            dataTask.resume()
//        }
//    }

    
}
