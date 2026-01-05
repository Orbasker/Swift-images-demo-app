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
    }
    
    // Computed property: filtered and sorted photos
    private var displayedPhotos: [Photo] {
        var result = photos
        
        // Filter by search text if provided
        if !searchText.isEmpty {
            result = result.filter { photo in
                photo.title.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Sort based on selected option
        switch sortOption {
        case .idAsc:
            result.sort { $0.id < $1.id }
        case .idDesc:
            result.sort { $0.id > $1.id }
        case .titleAsc:
            result.sort { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDesc:
            result.sort { $0.title.localizedCompare($1.title) == .orderedDescending }
        }
        
        return result
    }
    
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
            if !isLoading && displayedPhotos.isEmpty {
                HStack {
                    Spacer()
                    Text(searchText.isEmpty ? "No photos available" : "No photos match your search")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            // Display filtered and sorted photos
            ForEach(displayedPhotos) { photo in
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
            }
            }
            .navigationTitle("Photos")
            .searchable(text: $searchText, prompt: "Search photos by title")
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
                // Pull-to-refresh functionality
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
    
    /// Fetches photos from the API and updates the state
    private func loadPhotos() async {
        isLoading = true
        errorMessage = nil
        
        // Call the service function to fetch photos
        photos = await PhotoService.fetchPhotos()
        
        // Check if we got any photos
        if photos.isEmpty {
            errorMessage = "Failed to load photos. Check your internet connection and try again."
        } else {
            print("✅ Loaded \(photos.count) photos into view")
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}
