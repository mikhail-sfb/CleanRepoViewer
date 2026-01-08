# CleanRepoViewer

An iOS application showcasing **Clean Architecture** with **MVVM** pattern, built to demonstrate best practices in modern iOS development.

## 🏗️ Architecture

The project follows **Clean Architecture** principles with clear separation of concerns:

```
Presentation Layer (MVVM)
    ↓
Domain Layer (Use Cases + Repositories)
    ↓
Data Layer (Repository Implementation + DataSources)
    ↓
Network Layer (Alamofire)
```

### Layer Responsibilities

- **Presentation (MVVM)**: ViewControllers, ViewModels, Views (UI)
- **Domain**: Business logic, Use Cases, Repository protocols, Domain models
- **Data**: Repository implementations, DTOs, DataSources
- **Core**: Networking, Design System, Shared utilities

## 🎨 UI/UX

The UI is designed in the style of **Musica** - a music player with GPU-powered visualization (Onboarding screen from it):
<img width="257" height="549" alt="Screenshot 2025-12-22 at 16 46 07" src="https://github.com/user-attachments/assets/bef3c06f-09af-4de4-a205-6f84235fcc3a" />

- **Responsive Design**: Adaptive layouts for different screen sizes (iPhone/iPad)
- **Card-based UI**: Clean, modern repository cards with smooth interactions
- **Pull-to-Refresh**: Standard iOS refresh pattern
- **Infinite Scroll**: Pagination with smart prefetching
- **Empty States**: Elegant empty state views with clear messaging
- **Error Handling**: User-friendly error alerts

## 🛠️ Tech Stack

### Core Technologies
- **UIKit** (programmatic UI, no Storyboards)
- **SnapKit** - Declarative Auto Layout DSL (personal preference for cleaner constraints)
- **Alamofire** - HTTP networking with built-in decoding and interceptors

### Why These Choices?

**SnapKit**: More convenient and readable way to write constraints compared to raw NSLayoutConstraint. Personal preference after extensive use in production apps.

**Alamofire**: 
- Built-in `Decodable` support for seamless JSON parsing
- **Interceptors** for easy request/response logging without separate logging service
- More ergonomic API and development flow
- Industry-standard approach for iOS networking

## 🐛 Debug Features

The app includes **DEBUG-only** simulation buttons for testing edge cases:

- **Simulate Error** - Triggers error state UI
- **Clear Data** - Resets to empty state

**Why?** In well-written code, error states are difficult to reproduce naturally. These debug tools allow designers and QA to test all UI states without requiring actual failures or network manipulation.

```swift
#if DEBUG
func simulateError() {
    let debugError = NetworkError.serverError(statusCode: 500, message: "Debug simulation")
    handleError(debugError)
}
#endif
```

## 🧪 Testing

The project includes **Unit Tests** for:
- ViewModel logic
- Repository implementation
- Use Cases

**Note**: Tests were primarily written using AI-assisted tools for rapid development and coverage (on my commercial projects standart practise).

## 📦 Key Features

### Network Layer
- **Interceptors**: Logging interceptor for request/response debugging
- **Retry Policy**: Automatic retry logic for failed requests
- **Error Handling**: Comprehensive NetworkError enum with user-friendly messages

### Design System
- **ColorScheme**: Centralized color management
- **Typography**: Consistent text styles
- **Spacing**: Adaptive spacing system for different screen sizes
- **Reusable Components**: EmptyStateView, LoadingView, BaseCardView

### State Management
- **ViewState Enum**: Comprehensive state handling (initial, loading, loaded, refreshing, loadingMore, empty, error)
- **Single Source of Truth**: DisplayItem enum for unified table view data source
- **Proper State Transitions**: Prevents invalid state changes

## 📱 Screenshots
I USED SECRETS FOLDER IN .GITIGNORE TO HIDE THE KEY
<div style="overflow-x: auto; white-space: nowrap;">
  <img src="https://github.com/user-attachments/assets/dae5fee9-fece-49b4-9b4e-4ddeeb9e0958" alt="Repository List" height="400" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/375c81cd-bd36-447b-85f6-9093b340a6fc" alt="Loading State" height="400" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/aacd9920-595e-435a-ba50-d1eab0bedb61" alt="Empty State" height="400" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/d35ad827-e3e1-447a-845c-2aa051bd9e3b" alt="Error State" height="400" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/ada5774d-5e91-42d4-aa7b-427c2e116f4c" alt="iPad Portrait" height="400" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/0e045a8a-059b-499d-a970-0ef051d7acf8" alt="iPad Landscape" height="400" style="display: inline-block;">
  <img src="https://github.com/user-attachments/assets/661abcb1-221c-44f7-ac83-09a06561a12d" alt="Pull to Refresh" height="400" style="display: inline-block;">
</div>


