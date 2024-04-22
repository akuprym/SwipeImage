//
//  ViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 25.01.24.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    var currentPage = 1
    var currentPhotoIndex = 0
    let treshold: CGFloat = 75
    let photoIndexLimit = 9
    var currentIndex = 0
    
    var results: [APIResponse] = []
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        fetchPhotos(with: currentPage)
    }
    
    //     MARK: - Setup Cards
    
    fileprivate func setupCards() {
//
            for index in 0...9 {
                let names = [
                    results[index].urls.regular
                ]
                names.forEach { name in
                    let cardView = CardView()
                    cardView.imageView.sd_setImage(with: URL(string: name))
                    view.addSubview(cardView)
                    cardView.center = view.center
                }
            }
    }

    // MARK: - Network Service
    
    
    fileprivate func fetchPhotos(with currentPage: Int) {
       
            let unsplashAPIKey = "C_rjBM2WKe7RvLrSg0ZPGDjAvT8MfWqHQU8rzOfW4Rk"
            let urlString = "https://api.unsplash.com/photos/random?client_id=\(unsplashAPIKey)&count=10&page=\(currentPage)"
            
            guard let url = URL(string: urlString) else { return }
            
            let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let data = data else { return }
                
                do {
                    let jsonResult = try JSONDecoder().decode([APIResponse].self, from: data)
                    DispatchQueue.main.async {
                        self?.results = jsonResult
                        self?.setupCards()
                        self?.currentPage += 1
                    }
                } catch {
                    print(error)
                }
            }
            task.resume()
    
    }
}
