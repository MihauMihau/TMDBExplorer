import ComposableArchitecture
import SwiftUI
import GenreListFeature
import Common

@main
struct TMDBExplorerApp: App {
	let store = StoreOf<GenreList>(
		initialState: .initial,
		reducer: GenreList.init
	)
	
	var body: some Scene {
		WindowGroup {
			GenreListView(store: store)
		}
	}
}
