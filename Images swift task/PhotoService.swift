//
//  PhotoService.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation

/// Service for fetching photos from the BoringAPI using URLSession
struct PhotoService {
    /// API endpoint URL
    private static let apiURL = "https://boringapi.com/api/v1/photos/"
    
    /// Fetches photos from the remote API using URLSession
    /// - Returns: Array of Photo objects, or empty array if fetch fails
    static func fetchPhotos() async -> [Photo] {
        // Create URL from the API endpoint
        guard let url = URL(string: apiURL) else {
            print("Error: Invalid API URL")
            return []
        }
        
        do {
            // Fetch data from the API using URLSession with async/await
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP response status (basic error handling - bonus requirement)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Error: HTTP status code \(httpResponse.statusCode)")
                    return []
                }
            }
            
            // Decode JSON response into PhotosResponse wrapper
            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
            
            // Extract and return photos array from the response
            return photosResponse.photos
        } catch {
            // Basic error handling (bonus requirement) - print error message
            print("Error fetching photos: \(error.localizedDescription)")
            return []
        }
    }
}

