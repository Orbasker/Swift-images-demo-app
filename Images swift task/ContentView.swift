//
//  ContentView.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import SwiftUI

struct ContentView: View {
    // State property to hold the fetched photos
    @State private var photos: [Photo] = []
    
    // State property to track loading state (bonus feature)
    @State private var isLoading = false
    
    // Pagination state
    @State private var currentPage = 1
    @State private var totalPages = 1
    @State private var isLoadingMore = false
    
    // State property to track error messages
    @State private var errorMessage: String?
    
    // State property for selected photo to show in detail view
    @State private var selectedPhoto: Photo?
    
    // Search text for filtering photos
    @State private var searchText = ""
    
    // Sort option: titleAsc, titleDesc, idAsc, idDesc
    @State private var sortOption: SortOption = .idDesc
    
    // Sort options enum
    enum SortOption: String, CaseIterable {
        case idAsc = "ID ↑"
        case idDesc = "ID ↓"
        case titleAsc = "Title A-Z"
        case titleDesc = "Title Z-A"
        
        // Convert to API sort parameters
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
    
    // Search task for debouncing
    @State private var searchTask: Task<Void, Never>?
    
    var body: some View {
        NavigationStack {
            // Display list of photos immediately - show what we have without blocking
            List {
            // Show loading indicator at the top if still loading
            if isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading photos...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            // Show error message if API call failed
            if let errorMessage = errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .listRowSeparator(.hidden)
            }
            
            // Show message if no photos match filter/search
            if !isLoading && photos.isEmpty {
                HStack {
                    Spacer()
                    Text(searchText.isEmpty ? "No photos available" : "No photos match your search")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            // Display photos (already filtered and sorted by server)
            ForEach(photos) { photo in
                // Each row contains thumbnail image and title
                HStack {
                    // AsyncImage loads the image from the URL with error handling
                    AsyncImage(url: URL(string: photo.url)) { phase in
                        switch phase {
                        case .empty:
                            // Placeholder while image is loading
                            ProgressView()
                                .frame(width: 50, height: 50)
                        case .success(let image):
                            // Image loaded successfully
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 50, height: 50)
                        case .failure:
                            // Image failed to load - show fallback icon
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 50, height: 50)
                        @unknown default:
                            // Unknown state - show fallback
                            Image(systemName: "photo")
                                .foregroundColor(.gray)
                                .frame(width: 50, height: 50)
                        }
                    }
                    
                    // Photo title text
                    Text(photo.title)
                        .font(.body)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // Show full-size image when tapped
                    selectedPhoto = photo
                }
                .onAppear {
                    // Load more photos when the last photo appears (infinite scroll)
                    if photo.id == photos.last?.id && 
                       currentPage < totalPages && 
                       !isLoadingMore {
                        Task {
                            await loadMorePhotos()
                        }
                    }
                }
            }
            
            // Show loading indicator at the bottom when loading more pages
            if isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView("Loading more photos...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            }
            .navigationTitle("Photos")
            .searchable(text: $searchText, prompt: "Search photos by title")
            .onChange(of: searchText) { oldValue, newValue in
                // Debounce search - cancel previous task
                searchTask?.cancel()
                searchTask = Task {
                    // Wait 0.5 seconds before searching
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    if !Task.isCancelled {
                        await loadPhotos()
                    }
                }
            }
            .onChange(of: sortOption) { oldValue, newValue in
                // Reload when sort changes
                Task {
                    await loadPhotos()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Sort options menu
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button {
                                sortOption = option
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .refreshable {
                // Pull-to-refresh functionality - resets to first page
                await loadPhotos()
            }
            .onAppear {
                // Fetch photos when the view appears
                Task {
                    await loadPhotos()
                }
            }
            .fullScreenCover(item: $selectedPhoto) { photo in
                // Show full-size photo detail view
                PhotoDetailView(photo: photo)
            }
        }
    }
    
    /// Fetches the first page of photos from the API and updates the state
    private func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        currentPage = 1
        
        // Call the service function with current search and sort parameters
        guard let response = await PhotoService.fetchPhotos(
            page: 1,
            limit: 100,
            search: searchText.isEmpty ? nil : searchText,
            sortBy: sortOption.sortBy,
            sortOrder: sortOption.sortOrder
        ) else {
            errorMessage = "Failed to load photos. Check your internet connection and try again."
            isLoading = false
            return
        }
        
        // Update state with first page data
        photos = response.photos
        totalPages = response.totalPages
        
        if photos.isEmpty {
            errorMessage = searchText.isEmpty ? "No photos available." : "No photos match your search"
        } else {
            print("✅ Loaded page \(currentPage)/\(totalPages) - \(photos.count) photos")
        }
        
        isLoading = false
    }
    
    /// Loads the next page of photos and appends them to the existing list
    private func loadMorePhotos() async {
        guard currentPage < totalPages else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        // Fetch the next page with same search and sort parameters
        guard let response = await PhotoService.fetchPhotos(
            page: nextPage,
            limit: 100,
            search: searchText.isEmpty ? nil : searchText,
            sortBy: sortOption.sortBy,
            sortOrder: sortOption.sortOrder
        ) else {
            print("⚠️ Error: Failed to load page \(nextPage)")
            isLoadingMore = false
            return
        }
        
        // Append new photos to existing list
        photos.append(contentsOf: response.photos)
        currentPage = nextPage
        
        print("✅ Loaded page \(currentPage)/\(totalPages) - Total photos: \(photos.count)")
        
        isLoadingMore = false
    }
}

#Preview {
    ContentView()
}
