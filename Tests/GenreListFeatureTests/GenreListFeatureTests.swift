import ComposableArchitecture
import XCTest
@testable import GenreListFeature

@MainActor
final class GenreListFeatureTests: XCTestCase {
	
	func test_listFetchingError() async {
		let scheduler = DispatchQueue.test
		
		let store = TestStore(
			initialState: GenreList.State.init(
				genres: [],
				errorOccured: false
			),
			reducer: GenreList.init
		)
		store.dependencies.genreList.loadGenresList = {
			.mockErrorOccured
		}
		
		await store.send(.loadGenreList)
		
		await scheduler.advance()
		
		await store.receive(.genreListLoaded(.mockErrorOccured)) {
			$0 = .mockErrorOccured
		}
		
	}
	
	func test_listFetchingSuccess() async {
		let scheduler = DispatchQueue.test
		
		let store = TestStore(
			initialState: GenreList.State.init(
				genres: [],
				errorOccured: false
			),
			reducer: GenreList.init
		)
		store.dependencies.genreList.loadGenresList = {
			.mockSuccessfullyFetched
		}
		
		await store.send(.loadGenreList)
		
		await scheduler.advance()
		
		await store.receive(.genreListLoaded(.mockSuccessfullyFetched)) {
			$0 = .mockSuccessfullyFetched
		}
		
	}
	
	@MainActor
	func test_listItemTapped() async {		
		let store = TestStore(
			initialState: GenreList.State.mockTappedItem,
			reducer: GenreList.init
		)
		
		await store.send(.genreListItem(id: 0, action: .didTapItem)) {
			$0.movieList = .mock
		}
	}
}
