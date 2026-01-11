//
//  PhotosViewModel.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation
import SwiftUI

/// ViewModel for managing photos list state and business logic
@Observable
class PhotosViewModel {
    // MARK: - Published Properties
    var photos: [Photo] = []
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var currentPage = 1
    var totalPages = 1
    var searchText = ""
    var sortOption: SortOption = .idDesc
    var selectedPhoto: Photo?
    
    // MARK: - Dependencies
    private let repository: PhotoRepositoryProtocol
    
    // MARK: - Sort Options
    enum SortOption: String, CaseIterable {
        case idAsc = "ID ↑"
        case idDesc = "ID ↓"
        case titleAsc = "Title A-Z"
        case titleDesc = "Title Z-A"
        
        var sortBy: String {
            switch self {
            case .idAsc, .idDesc:
                return "id"
            case .titleAsc, .titleDesc:
                return "title"
            }
        }
        
        var sortOrder: String {
            switch self {
            case .idAsc, .titleAsc:
                return "asc"
            case .idDesc, .titleDesc:
                return "desc"
            }
        }
    }
    
    // MARK: - Search Task for Debouncing
    private var searchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(repository: PhotoRepositoryProtocol = PhotoRepository()) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    
    /// Loads the first page of photos from the repository
    func loadPhotos() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            currentPage = 1
        }
        
        let response = await repository.fetchPhotos(
            page: 1,
            limit: 100,
            search: searchText.isEmpty ? nil : searchText,
            sortBy: sortOption.sortBy,
            sortOrder: sortOption.sortOrder
        )
        
        await MainActor.run {
            if let response = response {
                photos = response.photos
                totalPages = response.totalPages
                
                if photos.isEmpty {
                    errorMessage = searchText.isEmpty ? "No photos available." : "No photos match your search"
                } else {
                    print("✅ Loaded page \(currentPage)/\(totalPages) - \(photos.count) photos")
                }
            } else {
                errorMessage = "Failed to load photos. Check your internet connection and try again."
            }
            
            isLoading = false
        }
    }
    
    /// Loads the next page of photos and appends them to the existing list
    func loadMorePhotos() async {
        guard currentPage < totalPages else { return }
        
        await MainActor.run {
            isLoadingMore = true
        }
        
        let nextPage = currentPage + 1
        
        let response = await repository.fetchPhotos(
            page: nextPage,
            limit: 100,
            search: searchText.isEmpty ? nil : searchText,
            sortBy: sortOption.sortBy,
            sortOrder: sortOption.sortOrder
        )
        
        await MainActor.run {
            if let response = response {
                photos.append(contentsOf: response.photos)
                currentPage = nextPage
                print("✅ Loaded page \(currentPage)/\(totalPages) - Total photos: \(photos.count)")
            } else {
                print("⚠️ Error: Failed to load page \(nextPage)")
            }
            
            isLoadingMore = false
        }
    }
    
    /// Handles search text changes with debouncing
    func handleSearchTextChange(_ newValue: String) {
        searchText = newValue
        
        // Cancel previous search task
        searchTask?.cancel()
        
        // Create new debounced search task
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            if !Task.isCancelled {
                await loadPhotos()
            }
        }
    }
    
    /// Handles sort option changes
    func handleSortOptionChange(_ newValue: SortOption) {
        sortOption = newValue
        Task {
            await loadPhotos()
        }
    }
    
    /// Checks if more photos should be loaded when a photo appears
    func shouldLoadMore(photoId: Int) -> Bool {
        return photoId == photos.last?.id && 
               currentPage < totalPages && 
               !isLoadingMore
    }
}

