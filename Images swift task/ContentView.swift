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
    
    var body: some View {
        NavigationStack {
            List {
                // Show loading indicator while fetching data (bonus requirement)
                if isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading photos...")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                
                // Display all photos in the list
                ForEach(photos) { photo in
                    // Each row contains thumbnail image and title
                    HStack {
                        // AsyncImage loads the image from the URL
                        AsyncImage(url: URL(string: photo.url)) { phase in
                            switch phase {
                            case .empty:
                                // Placeholder while image is loading
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                // Image loaded successfully - display as thumbnail
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
                    .onAppear {
                        // Load more photos when the last photo appears (infinite scroll)
                        if photo.id == photos.last?.id && currentPage < totalPages && !isLoadingMore {
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
            .onAppear {
                // Fetch photos when the app launches
                Task {
                    await loadPhotos()
                }
            }
        }
    }
    
    /// Fetches the first page of photos from the API and updates the state
    private func loadPhotos() async {
        isLoading = true
        currentPage = 1
        
        // Call the service function to fetch first page
        guard let response = await PhotoService.fetchPhotos(page: 1) else {
            print("⚠️ Error: Failed to load photos from API")
            isLoading = false
            return
        }
        
        // Update state with first page data
        photos = response.photos
        totalPages = response.totalPages
        
        print("✅ Successfully loaded \(photos.count) photos (Page \(currentPage)/\(totalPages))")
        
        isLoading = false
    }
    
    /// Loads the next page of photos and appends them to the existing list
    private func loadMorePhotos() async {
        guard currentPage < totalPages else { return }
        
        isLoadingMore = true
        let nextPage = currentPage + 1
        
        // Fetch the next page
        guard let response = await PhotoService.fetchPhotos(page: nextPage) else {
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
