//
//  ViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 25.01.24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var card: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var thumbImageView: UIImageView!
    
    @IBOutlet weak var resetButton: UIButton!
    
    var results: [Result] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view = UIView()
        view.backgroundColor = .gray
        view.addSubview(card)
        view.addSubview(resetButton)
        card.addSubview(imageView)
        fetchPhotos()
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

    
    func fetchPhotos() {
        
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=50&query=office&client_id=FrxT9u6XQRE_HVqjS9MhfYTH5LN0SsnhIp8VheooyRs"
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
        let urlString = self.results.randomElement()!.urls.regular
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

