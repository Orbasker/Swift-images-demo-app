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
    /// - Parameter page: The page number to fetch (defaults to 1)
    /// - Returns: PhotosResponse containing photos and pagination info, or nil if fetch fails
    static func fetchPhotos(page: Int = 1) async -> PhotosResponse? {
        // Build URL with pagination query parameter
        var urlComponents = URLComponents(string: apiURL)
        urlComponents?.queryItems = [URLQueryItem(name: "page", value: String(page))]
        
        guard let url = urlComponents?.url else {
            print("Error: Invalid API URL")
            return nil
        }
        
        do {
            // Fetch data from the API using URLSession with async/await
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP response status (basic error handling - bonus requirement)
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode != 200 {
                    print("Error: HTTP status code \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            // Decode JSON response into PhotosResponse wrapper
            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
            
            return photosResponse
        } catch {
            // Basic error handling (bonus requirement) - print error message
            print("Error fetching photos: \(error.localizedDescription)")
            return nil
        }
    }
}

