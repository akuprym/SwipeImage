//
//  MainTabBarController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 8.04.24.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupTabs()
    }

    fileprivate func setupTabs() {
        let photosVC = self.createNav(with: "Photos", image: UIImage(systemName: "photo"), vc: ViewController())
        let likedVC = self.createNav(with: "Liked", image: UIImage(systemName: "heart.fill"), vc: LikedViewController())
        
        self.setViewControllers([photosVC, likedVC], animated: true)
        
        let liked = (self.viewControllers?[1] as? UINavigationController)?.viewControllers.first as? LikedViewController
        
    }
    
    fileprivate func createNav(with title: String, image: UIImage?, vc: UIViewController) -> UINavigationController {
        
        let nav = UINavigationController(rootViewController: vc)
        
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        nav.viewControllers.first?.navigationItem.title = title + " Folder"
        
        return nav
    }
}
