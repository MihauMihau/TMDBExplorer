# TMDBExplorer

A simple application that fetches data from TMDB API (https://www.themoviedb.org/) and shows two lists - one with the genres of movies and second one with a list of films from a chosen by user genre. The app supports different movie list layout for iPhone and iPad. It also contains simple caching logic to not fetch the same data each time.

## 🛠 Tech stack

- [Xcode](https://developer.apple.com/xcode/) v15.2
- [Swift](https://swift.org/) v5.9
- [ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture) v1.9.3
- [Nuke](https://github.com/kean/Nuke)

## 🚀 Quick start

Open `TMDBExplorer.xcworkspace` in Xcode. After Xcode finishes fetching SPM dependencies, the project is ready for development. You can run the app using `TMDBExplorer` build scheme.

## 🧪 Testing

You can use scheme `Tests` to run the unit tests in Xcode.

## 📁 Project structure

The repository contains an Xcode workspace which should be used for development. The workspace contains a Swift Package and an Xcode project. The package defines all features and logic and is divided to modules. Each of these have correspondig build scheme which should be used when focusing on a single feature development.
