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
    let photoIndexLimit = 9
    var currentIndex = 0
    
    var results: [APIResponse] = []
    var images: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        fetchPhotos()
    }
    
    // MARK: - Network Service
    
    
    fileprivate func fetchPhotos() {
        
        let unsplashAPIKey = "H5-2v_xzHIa1VFAeuBUJwN6UE2iWijn3V5cZTGD_GJU"
        let urlString = "https://api.unsplash.com/photos/random?client_id=\(unsplashAPIKey)&count=10&page=\(currentPage)"
        
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
    
    //     MARK: - Setup Cards
    
    fileprivate func downloadImage() {
        var swipe = 0
    
        for index in 0...9 {
            swipe += 1
            if swipe > 9 && currentPage < 3 {
                currentPage += 1
                fetchPhotos()
            } else {
                
                let cardView = CardView()
                cardView.center = view.center
                view.addSubview(cardView)
                let urlString = self.results[index].urls.regular
                guard let url = URL(string: urlString) else { return }
                let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
                let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                    guard error == nil,
                          let data = data,
                          let response = response as? HTTPURLResponse,
                          response.statusCode == 200 else { return }
                    guard let image = UIImage(data: data) else { return }
                    DispatchQueue.main.async {
                        cardView.imageView.image = image
                    }
                }
                dataTask.resume()
            }
        }
    }
}
