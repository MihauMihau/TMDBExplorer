import ComposableArchitecture
import SwiftUI
import Localization

// MARK: - State
@Reducer
public struct MovieList {
	// MARK: - State
	@ObservableState
	public struct State: Equatable, Identifiable, Sendable {
		public var id: Int
		public var genreTitle: String
		public var items: IdentifiedArrayOf<MovieListItem.State>
		public var isFetching: Bool
		public var isFetchingPagination: Bool
		public var totalPages: Int
		public var page: Int
		public var isPaginationFinished: Bool
		public var errorOccured: Bool
		
		public init(
			id: Int,
			genreTitle: String,
			items: IdentifiedArrayOf<MovieListItem.State>,
			totalPages: Int,
			errorOccured: Bool = false,
			page: Int = 0,
			isFetching: Bool = true,
			isFetchingPagination: Bool = false,
			isPaginationFinished: Bool = false
		) {
			self.id = id
			self.genreTitle = genreTitle
			self.items = items
			self.totalPages = totalPages
			self.errorOccured = errorOccured
			self.page = page
			self.isFetching = isFetching
			self.isFetchingPagination = isFetchingPagination
			self.isPaginationFinished = isPaginationFinished
		}
		
		public static let empty: Self = .init(
			id: 0,
			genreTitle: "",
			items: .init(),
			totalPages: 0
		)
		
		#if DEBUG
		public static let mock: Self = .init(
			id: 0,
			genreTitle: "",
			items: [],
			totalPages: 1000,
			errorOccured: false
		)
		
		public static let mockErrorOccured: Self = .init(
			id: 0,
			genreTitle: "Action",
			items: [],
			totalPages: 1000,
			errorOccured: true,
			page: 1,
			isFetching: false
		)
		
		public static let mockFetchedSuccessfully: Self = .init(
			id: 1,
			genreTitle: "Action",
			items: [.mock],
			totalPages: 1000,
			errorOccured: false,
			page: 1,
			isFetching: false
		)
		#endif
	}
	
	// MARK: - Actions
	public enum Action: Equatable {
		case onAppear
		case loadMovieList
		case movieListLoaded(MovieList.State)
		case movieListItem(id: MovieListItem.State.ID, action: MovieListItem.Action)
	}
	
	// MARK: Dependencies
	@Dependency(\.movieList) var env
	// MARK: - Body
	public var body: some Reducer<State, Action> {
		Reduce { state, action in
			switch action {
			case .onAppear:
				return .send(.loadMovieList)
			case .loadMovieList:
				state.page += 1
				return .run {[
					id = state.id,
					genreTitle = state.genreTitle,
					page = state.page
				] send in
					let list = try await env.loadMovieList(id, genreTitle, page)
					await send(
						.movieListLoaded(list)
					)
				}
			case .movieListLoaded(let movieState):
				state.items += movieState.items
				state.genreTitle = movieState.genreTitle
				state.isFetching = false
				state.isFetchingPagination = false
				state.totalPages = movieState.totalPages
				state.errorOccured = movieState.errorOccured
				return .none
			case .movieListItem(id: let id, action: .onAppear):
				if id == state.items.last?.id && state.page < state.totalPages {
					state.isPaginationFinished = false
					state.isFetchingPagination = true
					return .send(.loadMovieList)
				} else {
					state.isPaginationFinished = true
				}
				return .none
			case .movieListItem:
				return .none
			}
		}
	}
	
	// MARK: Init
	public init() {}
}

// MARK: - Environment
public struct MovieListEnvironment {
	var loadMovieList: @Sendable (Int, String, Int) async throws -> MovieList.State
	
	public init(
		loadMovieList: @escaping @Sendable (Int, String, Int) async throws -> MovieList.State
	) {
		self.loadMovieList = loadMovieList
	}
}

public extension DependencyValues {
	var movieList: MovieListEnvironment {
		get { self[MovieListKey.self] }
		set { self[MovieListKey.self] = newValue }
	}
	enum MovieListKey: TestDependencyKey {
		public static let testValue: MovieListEnvironment = .init { _, _, _ in
			unimplemented("loadMovieList")
		}
		#if DEBUG
		public static let previewValue: MovieListEnvironment = .init(
			loadMovieList: { _, _, _ in .mock }
		)
		#endif
	}
}

// MARK: - View
public struct MovieListView: View {
	
	let store: StoreOf<MovieList>
	
	public init(store: StoreOf<MovieList>) {
		self.store = store
	}
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass

	public var body: some View {
		VStack {
			if store.errorOccured {
				HStack {
					Text(Localization.generalErrorMessage)
				}
				.frame(maxWidth: .infinity, maxHeight: 50)
				.foregroundColor(Color.white)
				.background(Color.red)
			}
			
			if store.isFetching {
				ProgressView()
			} else {
				ScrollView {
					VStack {
						if horizontalSizeClass == .regular && verticalSizeClass == .regular {
							LazyVGrid(
								columns: [
									GridItem(.flexible(minimum: 200, maximum: 300), alignment: .leading),
									GridItem(.flexible(minimum: 200, maximum: 300), alignment: .leading),
									GridItem(.flexible(minimum: 200, maximum: 300), alignment: .leading),
									GridItem(.flexible(minimum: 200, maximum: 300), alignment: .leading)
								],
								spacing: 60,
								content: {
									ForEachStore(
										store.scope(
											state: \.items,
											action: \.movieListItem
										),
										content: MovieListItemView.init(store:)
									)
								}
							)
						} else {
							LazyVGrid(
								columns: [
									GridItem(.flexible(minimum: 150, maximum: 400), alignment: .leading),
									GridItem(.flexible(minimum: 150, maximum: 400), alignment: .leading)
								],
								spacing: 12,
								content: {
									ForEachStore(
										store.scope(
											state: \.items,
											action: \.movieListItem
										),
										content: MovieListItemView.init(store:)
									)
								}
							)
						}
						if store.isFetchingPagination {
							ProgressView()
								.frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
								.background(Color.clear)
						}
					}
				}
				.padding([.vertical], 12)
			}
		}
		.navigationTitle(store.genreTitle)
		.task {
			await store.send(.onAppear).finish()
		}
	}
}

#if DEBUG
// MARK: Preview
#Preview {
	MovieListView(
		store: .init(
			initialState: MovieList.State.mock,
			reducer: MovieList.init
		)
	)
}

public extension MovieListEnvironment {
	static func mockErrorOccured(
	) -> Self {
		.init(
			loadMovieList: { _, _, _ in .mockErrorOccured }
		)
	}
	
	static func mockFetchedSuccessfully(
	) -> Self {
		.init(
			loadMovieList: { _, _, _ in .mockFetchedSuccessfully }
		)
	}
}
#endif
