//
//  ContentView.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import SwiftUI

struct ContentView: View {
    // ViewModel manages all state and business logic
    @State private var viewModel = PhotosViewModel()
    
    var body: some View {
        NavigationStack {
            // Display list of photos immediately - show what we have without blocking
            List {
            // Show loading indicator at the top if still loading
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading photos...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            // Show error message if API call failed
            if let errorMessage = viewModel.errorMessage {
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
            if !viewModel.isLoading && viewModel.photos.isEmpty {
                HStack {
                    Spacer()
                    Text(viewModel.searchText.isEmpty ? "No photos available" : "No photos match your search")
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            
            // Display photos (already filtered and sorted by server)
            ForEach(viewModel.photos) { photo in
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
                    viewModel.selectedPhoto = photo
                }
                .onAppear {
                    // Load more photos when the last photo appears (infinite scroll)
                    if viewModel.shouldLoadMore(photoId: photo.id) {
                        Task {
                            await viewModel.loadMorePhotos()
                        }
                    }
                }
            }
            
            // Show loading indicator at the bottom when loading more pages
            if viewModel.isLoadingMore {
                HStack {
                    Spacer()
                    ProgressView("Loading more photos...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            }
            .navigationTitle("Photos")
            .searchable(text: $viewModel.searchText, prompt: "Search photos by title")
            .onChange(of: viewModel.searchText) { oldValue, newValue in
                // Handle search with debouncing via ViewModel
                viewModel.handleSearchTextChange(newValue)
            }
            .onChange(of: viewModel.sortOption) { oldValue, newValue in
                // Reload when sort changes via ViewModel
                viewModel.handleSortOptionChange(newValue)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        // Sort options menu
                        ForEach(PhotosViewModel.SortOption.allCases, id: \.self) { option in
                            Button {
                                viewModel.handleSortOptionChange(option)
                            } label: {
                                HStack {
                                    Text(option.rawValue)
                                    if viewModel.sortOption == option {
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
                await viewModel.loadPhotos()
            }
            .onAppear {
                // Fetch photos when the view appears
                Task {
                    await viewModel.loadPhotos()
                }
            }
            .fullScreenCover(item: $viewModel.selectedPhoto) { photo in
                // Show full-size photo detail view
                PhotoDetailView(photo: photo)
            }
        }
    }
}

#Preview {
    ContentView()
}
