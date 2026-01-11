//
//  PhotoDetailView.swift
//  Images swift task
//
//  Created by Or Basker on 05/01/2026.
//

import SwiftUI
import Photos

/// View for displaying full-size photo with save and share options
struct PhotoDetailView: View {
    let photo: Photo
    @Environment(\.dismiss) var dismiss
    @State private var viewModel: PhotoDetailViewModel
    
    init(photo: Photo) {
        self.photo = photo
        self._viewModel = State(initialValue: PhotoDetailViewModel(photo: photo))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color.black.ignoresSafeArea()
                
                if viewModel.isLoading {
                    // Loading indicator
                    ProgressView()
                        .tint(.white)
                } else if let image = viewModel.image {
                    // Zoomable image view
                    ZoomableImageView(image: image)
                        .ignoresSafeArea()
                } else {
                    // Error state
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Failed to load image")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
            }
            .navigationTitle(viewModel.photoTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            viewModel.saveToPhotos()
                        } label: {
                            Label("Save to Photos", systemImage: "square.and.arrow.down")
                        }
                        
                        Button {
                            viewModel.showShareSheet = true
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.white)
                    }
                }
            }
            .onAppear {
                viewModel.loadFullSizeImage()
            }
            .sheet(isPresented: $viewModel.showShareSheet) {
                ShareSheet(activityItems: viewModel.shareActivityItems)
            }
            .alert("Save Photo", isPresented: $viewModel.showSaveAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.saveAlertMessage)
            }
        }
    }
}

/// Zoomable image view using UIScrollView for pinch-to-zoom
struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.delegate = context.coordinator
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 5.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .black
        scrollView.bouncesZoom = true
        
        // Image view - set initial frame to prevent black screen
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .clear
        
        // Double tap gesture for zoom (works better in simulator)
        let doubleTap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        imageView.addGestureRecognizer(doubleTap)
        
        scrollView.addSubview(imageView)
        context.coordinator.imageView = imageView
        context.coordinator.scrollView = scrollView
        
        // Set initial frame to make image visible immediately
        imageView.frame = CGRect(origin: .zero, size: image.size)
        scrollView.contentSize = image.size
        
        // Update layout after view is laid out
        DispatchQueue.main.async {
            context.coordinator.updateImageLayout()
        }
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        // Update layout when view size changes
        DispatchQueue.main.async {
            context.coordinator.updateImageLayout()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(image: image)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var imageView: UIImageView?
        var scrollView: UIScrollView?
        let image: UIImage
        
        init(image: UIImage) {
            self.image = image
        }
        
        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            return imageView
        }
        
        func updateImageLayout() {
            guard let scrollView = scrollView, let imageView = imageView else { return }
            
            // Wait for bounds to be set
            guard scrollView.bounds.width > 0 && scrollView.bounds.height > 0 else {
                // Retry after a short delay if bounds aren't ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.updateImageLayout()
                }
                return
            }
            
            let scrollViewSize = scrollView.bounds.size
            let imageSize = image.size
            
            // Guard against zero image size
            guard imageSize.width > 0 && imageSize.height > 0 else { return }
            
            // Calculate scale to fit image in scroll view
            let widthScale = scrollViewSize.width / imageSize.width
            let heightScale = scrollViewSize.height / imageSize.height
            let minScale = min(widthScale, heightScale)
            
            // Set content size and image frame
            scrollView.zoomScale = 1.0
            imageView.frame = CGRect(origin: .zero, size: imageSize)
            scrollView.contentSize = imageSize
            scrollView.minimumZoomScale = minScale
            scrollView.maximumZoomScale = max(minScale * 5.0, 1.0)
            scrollView.zoomScale = minScale
            
            // Center image
            centerImage()
        }
        
        func centerImage() {
            guard let scrollView = scrollView, let imageView = imageView else { return }
            
            let boundsSize = scrollView.bounds.size
            var frameToCenter = imageView.frame
            
            if frameToCenter.size.width < boundsSize.width {
                frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2
            } else {
                frameToCenter.origin.x = 0
            }
            
            if frameToCenter.size.height < boundsSize.height {
                frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2
            } else {
                frameToCenter.origin.y = 0
            }
            
            imageView.frame = frameToCenter
        }
        
        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            centerImage()
        }
        
        func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
            centerImage()
        }
        
        // Double tap to zoom in/out
        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = scrollView else { return }
            
            if scrollView.zoomScale > scrollView.minimumZoomScale {
                // Zoom out
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                // Zoom in to 2x at tap location
                let point = gesture.location(in: imageView)
                let zoomScale: CGFloat = 2.0
                let scrollSize = scrollView.frame.size
                let w = scrollSize.width / zoomScale
                let h = scrollSize.height / zoomScale
                let x = point.x - (w / 2.0)
                let y = point.y - (h / 2.0)
                let rect = CGRect(x: x, y: y, width: w, height: h)
                scrollView.zoom(to: rect, animated: true)
            }
        }
    }
}

/// Share sheet wrapper for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

