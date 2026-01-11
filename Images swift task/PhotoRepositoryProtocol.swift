//
//  PhotoRepositoryProtocol.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation

/// Protocol defining the interface for photo data repository
protocol PhotoRepositoryProtocol {
    /// Fetches photos from the data source
    /// - Parameters:
    ///   - page: The page number to fetch
    ///   - limit: Number of photos per page
    ///   - search: Optional search query to filter photos
    ///   - sortBy: Field to sort by
    ///   - sortOrder: Sort order "asc" or "desc"
    /// - Returns: PhotosResponse containing photos and pagination info, or nil if fetch fails
    func fetchPhotos(
        page: Int,
        limit: Int,
        search: String?,
        sortBy: String,
        sortOrder: String
    ) async -> PhotosResponse?
}

