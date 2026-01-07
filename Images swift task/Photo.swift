//
//  Photo.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation

/// Photo model matching the BoringAPI response structure
/// Contains the required fields: id, title, and url
struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
}

/// Wrapper model for the BoringAPI response
/// The API returns a JSON object with success, message, count, total_pages, and photos array
struct PhotosResponse: Codable {
    let success: Bool
    let message: String
    let count: Int
    let totalPages: Int
    let photos: [Photo]
    
    // Custom coding keys to map JSON field names (snake_case to camelCase)
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case count
        case totalPages = "total_pages"
        case photos
    }
}

