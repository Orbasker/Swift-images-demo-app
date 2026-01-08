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
    /// - Parameters:
    ///   - page: The page number to fetch (defaults to 1)
    ///   - limit: Number of photos per page (defaults to 100, max: 100)
    ///   - search: Optional search query to filter photos by title or description
    ///   - sortBy: Field to sort by (defaults to "id")
    ///   - sortOrder: Sort order "asc" or "desc" (defaults to "desc")
    /// - Returns: PhotosResponse containing photos and pagination info, or nil if fetch fails
    static func fetchPhotos(
        page: Int = 1,
        limit: Int = 100,
        search: String? = nil,
        sortBy: String = "id",
        sortOrder: String = "desc"
    ) async -> PhotosResponse? {
        // Build URL with query parameters
        var urlComponents = URLComponents(string: apiURL)
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "limit", value: String(min(limit, 100))), // Cap at 100
            URLQueryItem(name: "sort_by", value: sortBy),
            URLQueryItem(name: "sort_order", value: sortOrder)
        ]
        
        // Add search parameter if provided
        if let search = search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }
        
        urlComponents?.queryItems = queryItems
        
        guard let url = urlComponents?.url else {
            print("Error: Invalid API URL")
            return nil
        }
        
        do {
            print("📡 Fetching photos from: \(url.absoluteString)")
            // Fetch data from the API using async/await
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Check HTTP response status
            if let httpResponse = response as? HTTPURLResponse {
                print("📥 HTTP Status: \(httpResponse.statusCode)")
                if httpResponse.statusCode != 200 {
                    print("⚠️ Unexpected HTTP status code: \(httpResponse.statusCode)")
                    return nil
                }
            }
            
            print("📦 Received \(data.count) bytes of data")
            
            // Decode JSON response into PhotosResponse wrapper
            let photosResponse = try JSONDecoder().decode(PhotosResponse.self, from: data)
            print("✅ Successfully decoded response: \(photosResponse.message)")
            print("📊 Total photos in response: \(photosResponse.count)")
            print("📄 Page \(page)/\(photosResponse.totalPages)")
            
            return photosResponse
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
            return nil
        } catch {
            // Handle network and other errors
            print("❌ Error fetching photos: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("   URL Error Code: \(urlError.code.rawValue)")
                print("   URL Error Description: \(urlError.localizedDescription)")
            }
            return nil
        }
    }
}

