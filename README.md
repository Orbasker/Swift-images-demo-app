# Images Swift Task

A SwiftUI app that displays a list of photos fetched from the BoringAPI with enhanced features for browsing, searching, and viewing photos.

## How to Run

1. Open `Images swift task.xcodeproj` in Xcode
2. Select a simulator or device
3. Press ⌘R to run the app

The app will automatically fetch photos from the API when it launches.

## What I Built

### Core Requirements Met

- **UI**: SwiftUI screen with a vertical list showing photos
  - Each row displays a thumbnail image (50x50) and the photo title
  - Uses `List`, `HStack`, `VStack`, and `AsyncImage` as required
  - Navigation stack with search and sort capabilities

- **Data Model**: Created `Photo` struct matching the API response
  - Fields: `id`, `title`, `url`, plus optional fields (`description`, `fileSize`, `height`, `width`)
  - Created `PhotosResponse` wrapper to handle the API's JSON structure
  - Properly handles snake_case to camelCase conversion using `CodingKeys`

- **Networking**: Implemented API fetching using `URLSession`
  - Fetches from `https://boringapi.com/api/v1/photos/`
  - Decodes JSON response into Swift models
  - Uses async/await for network calls
  - Comprehensive error handling with detailed logging

- **App Behavior**: 
  - Fetches photos automatically when app launches
  - Handles errors gracefully with user-friendly messages
  - Shows loading states and empty states appropriately

### Enhanced Features

- ✅ **Search functionality**: Search photos by title using the built-in search bar
- ✅ **Sorting options**: Sort photos by ID or title, ascending or descending
- ✅ **Photo detail view**: Tap any photo to view it full-screen with zoom capabilities
- ✅ **Zoom & pan**: Pinch-to-zoom and double-tap to zoom on full-size images
- ✅ **Save to Photos**: Save any photo directly to your device's photo library
- ✅ **Share functionality**: Share photos using the native iOS share sheet
- ✅ **Pull-to-refresh**: Pull down on the list to refresh photos from the API
- ✅ **Loading indicators**: Shows progress views during data fetching and image loading
- ✅ **Error handling**: Comprehensive error handling with user-friendly messages
- ✅ **Empty states**: Clear messaging when no photos are available or match search criteria

## What I Found Challenging

1. **JSON decoding**: Mapping the API's snake_case field names (`total_pages`, `file_size`) to Swift's camelCase convention required careful use of `CodingKeys`.

2. **Zoomable image view**: Implementing pinch-to-zoom and double-tap zoom using `UIScrollView` and `UIViewRepresentable` required understanding UIKit integration with SwiftUI.

3. **Photo library permissions**: Handling photo library access permissions and providing clear feedback to users when saving photos.

4. **State management**: Managing multiple state properties (loading, errors, search, sort) while keeping the UI responsive and the code maintainable.

5. **Async image loading**: Ensuring smooth image loading with proper placeholders and error states for both thumbnails and full-size images.

## Project Structure

```
Images swift task/
├── Images_swift_taskApp.swift    # App entry point
├── ContentView.swift              # Main UI with list, search, and sort
├── PhotoDetailView.swift          # Full-screen photo view with zoom, save, and share
├── Photo.swift                    # Data models (Photo, PhotosResponse)
└── PhotoService.swift             # Network service for API calls
```

## Features Overview

### Main Screen
- **List View**: Scrollable list of photos with thumbnails and titles
- **Search Bar**: Filter photos by title in real-time
- **Sort Menu**: Access sorting options from the toolbar
- **Pull-to-Refresh**: Swipe down to reload photos from the API

### Photo Detail View
- **Full-Screen Display**: Tap any photo to view it full-screen
- **Zoom Controls**: Pinch to zoom or double-tap to zoom in/out
- **Save to Photos**: Save images to your device's photo library
- **Share**: Share photos via the native iOS share sheet

## Notes

- The app fetches all photos from the first page of the API
- Images load asynchronously using `AsyncImage` for thumbnails and `URLSession` for full-size images
- If a network request fails, the app shows an error message but doesn't crash
- All photos are displayed in a scrollable list with search and sort capabilities
- Photo library access is requested when saving photos for the first time
