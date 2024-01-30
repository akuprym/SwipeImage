//
//  APIResponse.swift
//  Tinder-like-SwipeApp
//
//  Created by admin on 30.01.24.
//

import Foundation

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}

struct Result: Codable {
    let id: String
    let urls: URLS
}

struct URLS: Codable {
    let regular: String
}

