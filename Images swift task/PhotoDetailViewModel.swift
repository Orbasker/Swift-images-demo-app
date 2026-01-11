//
//  PhotoDetailViewModel.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import Foundation
import SwiftUI
import Photos

/// ViewModel for managing photo detail view state and business logic
@Observable
class PhotoDetailViewModel {
    // MARK: - Published Properties
    var image: UIImage?
    var isLoading = true
    var showShareSheet = false
    var showSaveAlert = false
    var saveAlertMessage = ""
    
    // MARK: - Dependencies
    private let photo: Photo
    
    // MARK: - Initialization
    init(photo: Photo) {
        self.photo = photo
    }
    
    // MARK: - Public Methods
    
    /// Loads the full-size image from URL
    func loadFullSizeImage() {
        guard let url = URL(string: photo.url) else {
            Task { @MainActor in
                isLoading = false
            }
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let loadedImage = UIImage(data: data) {
                    await MainActor.run {
                        self.image = loadedImage
                        self.isLoading = false
                    }
                } else {
                    await MainActor.run {
                        self.isLoading = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Saves the image to the device's photo library
    func saveToPhotos() {
        guard let image = image else {
            saveAlertMessage = "Image not available"
            showSaveAlert = true
            return
        }
        
        // Request photo library access
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            
            if status == .authorized || status == .limited {
                // Save to photo library
                PHPhotoLibrary.shared().performChanges({
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                }) { success, error in
                    DispatchQueue.main.async {
                        if success {
                            self.saveAlertMessage = "Photo saved successfully!"
                        } else {
                            self.saveAlertMessage = "Failed to save photo: \(error?.localizedDescription ?? "Unknown error")"
                        }
                        self.showSaveAlert = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.saveAlertMessage = "Photo library access denied. Please enable it in Settings."
                    self.showSaveAlert = true
                }
            }
        }
    }
    
    /// Returns the photo title
    var photoTitle: String {
        photo.title
    }
    
    /// Returns activity items for sharing
    var shareActivityItems: [Any] {
        var items: [Any] = [photo.title]
        if let image = image {
            items.insert(image, at: 0)
        }
        return items
    }
}

