//
//  Photo.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation

/// Photo model matching the BoringAPI response structure
struct Photo: Codable, Identifiable {
    let id: Int
    let title: String
    let url: String
    // Optional fields that may be present but not required for display
    let description: String?
    let fileSize: Int?
    let height: Int?
    let width: Int?
    
    // Custom coding keys to map JSON field names
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url
        case description
        case fileSize = "file_size"
        case height
        case width
    }
}

/// Wrapper model for the BoringAPI response
struct PhotosResponse: Codable {
    let success: Bool
    let message: String
    let count: Int
    let totalPages: Int
    let photos: [Photo]
    
    // Custom coding keys to map JSON field names
    enum CodingKeys: String, CodingKey {
        case success
        case message
        case count
        case totalPages = "total_pages"
        case photos
    }
}

