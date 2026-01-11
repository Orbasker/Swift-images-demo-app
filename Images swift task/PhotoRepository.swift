//
//  PhotoRepository.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation

/// Concrete implementation of PhotoRepositoryProtocol using PhotoService
struct PhotoRepository: PhotoRepositoryProtocol {
    /// Fetches photos from the remote API via PhotoService
    func fetchPhotos(
        page: Int,
        limit: Int,
        search: String?,
        sortBy: String,
        sortOrder: String
    ) async -> PhotosResponse? {
        return await PhotoService.fetchPhotos(
            page: page,
            limit: limit,
            search: search,
            sortBy: sortBy,
            sortOrder: sortOrder
        )
    }
}

