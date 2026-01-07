# Images Swift Task

A simple SwiftUI app that displays a list of photos fetched from the BoringAPI.

## How to Run

1. Open `Images swift task.xcodeproj` in Xcode
2. Select a simulator or device
3. Press ⌘R to run the app

The app will automatically fetch photos from the API when it launches.

## What I Built

### Requirements Met

- **UI**: Single SwiftUI screen with a vertical list showing photos
  - Each row displays a thumbnail image (50x50) and the photo title
  - Uses `List`, `HStack`, `VStack`, and `AsyncImage` as required

- **Data Model**: Created `Photo` struct matching the API response
  - Fields: `id`, `title`, `url`
  - Also created `PhotosResponse` wrapper to handle the API's JSON structure

- **Networking**: Implemented API fetching using `URLSession`
  - Fetches from `https://boringapi.com/api/v1/photos/`
  - Decodes JSON response into Swift models
  - Uses async/await for network calls

- **App Behavior**: 
  - Fetches photos automatically when app launches
  - Handles errors gracefully (shows empty list if fetch fails, doesn't crash)

### Bonus Features

- ✅ **Loading indicator**: Shows a progress view while fetching data
- ✅ **Error handling**: Basic error handling with print statements for debugging
- ✅ **Comments**: Added comments throughout the code explaining what each part does

## What I Found Challenging

1. **JSON decoding**: Mapping the API's snake_case field names (`total_pages`) to Swift's camelCase convention required using `CodingKeys`.

2. **Error handling**: Making sure the app doesn't crash on network failures while still providing useful feedback was important.

3. **SwiftUI state management**: Understanding when to use `@State` and how async functions interact with SwiftUI views took some getting used to.

## Project Structure

```
Images swift task/
├── Images_swift_taskApp.swift    # App entry point
├── ContentView.swift              # Main UI with list of photos
├── Photo.swift                    # Data models
└── PhotoService.swift             # Network service for API calls
```

## Notes

- The app fetches all photos from the first page of the API
- Images load asynchronously using AsyncImage
- If a network request fails, the app shows an empty list (doesn't crash)
- All photos are displayed in a scrollable list

