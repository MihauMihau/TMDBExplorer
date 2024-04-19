import ComposableArchitecture
import XCTest
@testable import MovieListFeature

@MainActor
final class MovieListFeatureTests: XCTestCase {
	
	func test_listFetchingError() async {
		let scheduler = DispatchQueue.test
		
		let store = TestStore(
			initialState: MovieList.State.init(
				id: 0,
				genreTitle: "Action",
				items: [],
				totalPages: 1000,
				errorOccured: false,
				page: 0,
				isFetching: true,
				isFetchingPagination: false
			),
			reducer: MovieList.init
		)
		store.dependencies.movieList.loadMovieList = { _, _, _ in
			.mockErrorOccured
		}
		
		await store.send(.loadMovieList) {
			$0.page = 1
		}
		
		await scheduler.advance()
		
		await store.receive(.movieListLoaded(.mockErrorOccured)) {
			$0 = .mockErrorOccured
		}
	}
	
	func test_listFetchingSuccess() async {
		let scheduler = DispatchQueue.test
		
		let store = TestStore(
			initialState: MovieList.State.init(
				id: 1,
				genreTitle: "Action",
				items: [],
				totalPages: 1000,
				errorOccured: false,
				page: 0,
				isFetching: true,
				isFetchingPagination: false
			),
			reducer: MovieList.init
		)
		store.dependencies.movieList.loadMovieList = { _, _, _ in
			.mockFetchedSuccessfully
		}
		
		await store.send(.loadMovieList) {
			$0.page = 1
		}
		
		await scheduler.advance()
		
		await store.receive(.movieListLoaded(.mockFetchedSuccessfully)) {
			$0 = .mockFetchedSuccessfully
		}
	}
	
	func test_listFetchingPaginationExceeded() async {
		let store = TestStore(
			initialState: MovieList.State.init(
				id: 1,
				genreTitle: "Action",
				items: [.mock],
				totalPages: 1000,
				errorOccured: false,
				page: 1000,
				isFetching: false,
				isFetchingPagination: true,
				isPaginationFinished: false
			),
			reducer: MovieList.init
		)
		
		await store.send(.movieListItem(id: 0, action: .onAppear)) {
			$0.isPaginationFinished = true
		}
	}
}

