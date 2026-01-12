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
    /// Computed property that returns filtered and sorted photos from cache
    var photos: [Photo] {
        let filtered = filterPhotos(cachedPhotos, searchText: searchText)
        return sortPhotos(filtered)
    }
    
    var isLoading = false
    var isLoadingMore = false
    var errorMessage: String?
    var currentPage = 1
    var totalPages = 1
    var searchText = ""
    var sortOption: SortOption = .idDesc
    var selectedPhoto: Photo?
    
    // MARK: - Private Properties
    /// Cache of all fetched photos (unsorted, unfiltered, raw from API)
    /// This contains ALL photos we've loaded, regardless of search
    private var cachedPhotos: [Photo] = []
    
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
    
    // MARK: - Initialization
    init(repository: PhotoRepositoryProtocol = PhotoRepository()) {
        self.repository = repository
    }
    
    // MARK: - Private Methods
    
    /// Filters photos locally based on search text (searches in title and description)
    private func filterPhotos(_ photosToFilter: [Photo], searchText: String) -> [Photo] {
        guard !searchText.isEmpty else {
            return photosToFilter
        }
        
        let searchLower = searchText.lowercased()
        return photosToFilter.filter { photo in
            // Search in title
            photo.title.lowercased().contains(searchLower) ||
            // Search in description if available
            (photo.description?.lowercased().contains(searchLower) ?? false)
        }
    }
    
    /// Sorts photos based on the current sort option
    private func sortPhotos(_ photosToSort: [Photo]) -> [Photo] {
        switch sortOption {
        case .idAsc:
            return photosToSort.sorted { $0.id < $1.id }
        case .idDesc:
            return photosToSort.sorted { $0.id > $1.id }
        case .titleAsc:
            return photosToSort.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDesc:
            return photosToSort.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }
    }
    
    // MARK: - Public Methods
    
    /// Loads the first page of photos from the repository
    /// Fetches from API and populates cache (no search filter - we filter locally)
    func loadPhotos() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            currentPage = 1
        }
        
        // Fetch ALL photos (no search filter) - we'll filter locally
        // Use default sort (ID ascending) for consistent caching
        let response = await repository.fetchPhotos(
            page: 1,
            limit: 100,
            search: nil, // Always fetch all photos, filter locally
            sortBy: "id",
            sortOrder: "asc"
        )
        
        await MainActor.run {
            if let response = response {
                // Update cache with fetched photos (all photos, not filtered)
                cachedPhotos = response.photos
                totalPages = response.totalPages
                
                // Photos will be automatically filtered and sorted via computed property
                let filteredAndSortedCount = photos.count
                
                if filteredAndSortedCount == 0 {
                    errorMessage = searchText.isEmpty ? "No photos available." : "No photos match your search"
                } else {
                    print("✅ Loaded page \(currentPage)/\(totalPages) - \(cachedPhotos.count) total cached, \(filteredAndSortedCount) after filter/sort")
                }
            } else {
                cachedPhotos = []
                errorMessage = "Failed to load photos. Check your internet connection and try again."
            }
            
            isLoading = false
        }
    }
    
    /// Loads the next page of photos and appends them to the existing list
    /// Fetches from API, appends to cache (no search filter - we filter locally)
    func loadMorePhotos() async {
        guard currentPage < totalPages else { return }
        
        await MainActor.run {
            isLoadingMore = true
        }
        
        let nextPage = currentPage + 1
        
        // Fetch ALL photos (no search filter) - we'll filter locally
        // Use default sort (ID ascending) for consistent caching
        let response = await repository.fetchPhotos(
            page: nextPage,
            limit: 100,
            search: nil, // Always fetch all photos, filter locally
            sortBy: "id",
            sortOrder: "asc"
        )
        
        await MainActor.run {
            if let response = response {
                // Append to cache (all photos, not filtered)
                cachedPhotos.append(contentsOf: response.photos)
                currentPage = nextPage
                
                // Photos will be automatically filtered and sorted via computed property
                let filteredAndSortedCount = photos.count
                print("✅ Loaded page \(currentPage)/\(totalPages) - \(cachedPhotos.count) total cached, \(filteredAndSortedCount) after filter/sort")
            } else {
                print("⚠️ Error: Failed to load page \(nextPage)")
            }
            
            isLoadingMore = false
        }
    }
    
    /// Handles search text changes
    /// Filters cached photos locally - no API call needed
    func handleSearchTextChange(_ newValue: String) {
        searchText = newValue
        // No API call needed - photos computed property will automatically filter and sort
        // The debouncing is handled by SwiftUI's searchable modifier
        print("🔍 Search changed to '\(newValue)' - filtering cached photos locally")
    }
    
    /// Handles sort option changes
    /// Sorts cached photos locally without refetching from API
    func handleSortOptionChange(_ newValue: SortOption) {
        sortOption = newValue
        // No API call needed - photos computed property will automatically re-sort
        print("🔄 Sort changed to \(newValue.rawValue) - sorting cached photos locally")
    }
    
    /// Checks if more photos should be loaded when a photo appears
    func shouldLoadMore(photoId: Int) -> Bool {
        return photoId == photos.last?.id && 
               currentPage < totalPages && 
               !isLoadingMore
    }
}

