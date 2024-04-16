//
//  LikedViewController.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 10.04.24.
//

import UIKit

class LikedViewController: UIViewController, UICollectionViewDataSource {
    
    var collectionView: UICollectionView?
    
    var likedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.dataSource = self
        collectionView?.delegate = self
    }
}

extension LikedViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return likedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! LikedCollectionViewCell
        cell.imageView.image = likedImages[indexPath.item]
        return cell
    }
       
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 100, height: 100)
    }
    
}
