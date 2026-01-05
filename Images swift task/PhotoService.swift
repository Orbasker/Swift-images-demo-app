//
//  PhotoService.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation

/// Service for fetching photos from the BoringAPI
struct PhotoService {
    /// API endpoint URL
    private static let apiURL = "https://boringapi.com/api/v1/photos/"
    
    /// Fetches photos from the remote API
    /// - Returns: Array of Photo objects, or empty array if fetch fails
    static func fetchPhotos() async -> [Photo] {
        // Create URL from the API endpoint
        guard let url = URL(string: apiURL) else {
            print("Error: Invalid API URL")
            return []
        }
        
        do {
            print("📡 Fetching photos from: \(apiURL)")
            // Fetch data from the API using async/await
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("⚠️ Unexpected HTTP status code: \(httpResponse.statusCode)")
                }
            }
            
            print("📦 Received \(data.count) bytes of data")
            
            // Decode JSON response into PhotosResponse wrapper
            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
            print("✅ Successfully decoded response: \(photosResponse.message)")
            print("📊 Total photos in response: \(photosResponse.count)")
            
            // Extract photos array from the response
            let photos = photosResponse.photos
            print("✅ Successfully decoded \(photos.count) photos")
            
            return photos
        } catch let decodingError as DecodingError {
            // Handle JSON decoding errors specifically
            print("❌ JSON Decoding Error: \(decodingError)")
            switch decodingError {
            case .keyNotFound(let key, let context):
                print("   Missing key: \(key.stringValue) - \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("   Type mismatch for type: \(type) - \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("   Missing value for type: \(type) - \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("   Data corrupted: \(context.debugDescription)")
            @unknown default:
                print("   Unknown decoding error")
            }
            return []
        } catch {
            // Handle network and other errors
            print("❌ Error fetching photos: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("   URL Error Code: \(urlError.code.rawValue)")
                print("   URL Error Description: \(urlError.localizedDescription)")
            }
            return []
        }
    }
}

