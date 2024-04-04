//
//  ViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 25.01.24.
//

import UIKit

class ViewController: UIViewController {
    
    var currentPage = 1
    var isLoading = false
    var currentPhotoIndex = 0
    let treshold: CGFloat = 75
    
//    var photos: [UIImage] = []
    
    
    var cardView: UIView!
    var imageView: UIImageView!
    var thumbImageView: UIImageView!
    

    
    //    @IBOutlet weak var imageView: UIImageView!
    //
    //    @IBOutlet weak var thumbImageView: UIImageView!
    //
    //    @IBOutlet weak var resetButton: UIButton!
    //
    var results: [Result] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        cardView = UIView(frame: CGRect(x: 80, y: 200, width: 300, height: 500))
        cardView.layer.cornerRadius = 10
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.3
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        view.addSubview(cardView)
        cardView.backgroundColor = .red
        imageView = UIImageView(frame: cardView.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cardView.addSubview(imageView)
        fetchPhotos()
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        cardView.addGestureRecognizer(panGesture)
        
//        view.addSubview(thumbImageView)
//        thumbImageView.frame = imageView.bounds
        
    }
    
    
    
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
    
    fileprivate func handleChangedState(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        // rotation + conversion degrees to radians
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * CGFloat.pi / 180
        
        let rotationTransformation = CGAffineTransform(rotationAngle: angle)
        cardView.transform = rotationTransformation.translatedBy(x: translation.x, y: translation.y)
    }
    
    fileprivate func handleEndedState(_ gesture: UIPanGestureRecognizer) {
        
//        let xFromCenter = imageView.center.x - view.center.x
        
        cardView.center = CGPoint(x: view.center.x + gesture.translation(in: nil).x, y: view.center.y + gesture.translation(in: nil).y)
        
        if cardView.center.x < treshold {
            // Dislike
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.cardView.center = CGPoint(x: self.cardView.frame.origin.x - self.cardView.frame.width/2, y: self.view.center.y + self.treshold)
            }
            resetCard()
        } else if cardView.center.x > view.frame.width - treshold {
            // Like
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1) {
                self.cardView.center = CGPoint(x: self.view.frame.maxX + self.view.frame.width/2, y: self.imageView.center.y + self.treshold)
            }
            resetCard()
        } else {
            cardView.transform = .identity
            cardView.center = view.center
        }
        
    }
    
    
    func resetCard() {
        UIView.animate(withDuration: 0.5) {
            self.currentPhotoIndex += 1
            self.cardView.transform = .identity
            self.cardView.center = self.view.center
            self.downloadImage()
//            self.thumbImageView.alpha = 0
//            self.cardView.alpha = 1
        }
    }
    
    
    func fetchPhotos() {
        
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=50&query=random&client_id=FrxT9u6XQRE_HVqjS9MhfYTH5LN0SsnhIp8VheooyRs"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else { return }
            
            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self.results = jsonResult.results
                    self.downloadImage()
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }

    
    func downloadImage() {
        
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
