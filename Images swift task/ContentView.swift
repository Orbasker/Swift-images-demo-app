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
    
    /// Fetches photos from the API and updates the state
    private func loadPhotos() async {
        isLoading = true
        
        // Call the service function to fetch photos
        photos = await PhotoService.fetchPhotos()
        
        // Basic error handling (bonus requirement) - print error if no photos loaded
        if photos.isEmpty {
            print("⚠️ Error: Failed to load photos from API")
        } else {
            print("✅ Successfully loaded \(photos.count) photos")
        }
        
        isLoading = false
    }
}

#Preview {
    ContentView()
}
