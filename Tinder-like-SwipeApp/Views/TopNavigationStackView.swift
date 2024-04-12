//
//  TopNavigationStackView.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 8.04.24.
//

import UIKit

class TopNavigationStackView: UIStackView {

    let likeButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
//        heightAnchor.constraint(equalToConstant: 60).isActive = true
        likeButton.setImage(UIImage(systemName: "heart.fill")?.withRenderingMode(.alwaysOriginal), for: .normal)
        likeButton.setTitleColor(.red, for: .normal)
        addArrangedSubview(likeButton)
        
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
