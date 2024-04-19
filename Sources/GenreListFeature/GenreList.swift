import ComposableArchitecture
import SwiftUI
import MovieListFeature
import Localization

// MARK: - Reducer
@Reducer
public struct GenreList {
	// MARK: - State
	@ObservableState
	public struct State: Equatable {
		public var genres: IdentifiedArrayOf<GenreListItem.State>
		public var movieList: MovieList.State = .empty
		public var isPresentingMovieList: Bool
		public var isFetching: Bool
		public var errorOccured: Bool
		
		public init(
			genres: IdentifiedArrayOf<GenreListItem.State>,
			errorOccured: Bool = false,
			isFetching: Bool = true,
			isPresentingMovieList: Bool = false
		) {
			self.genres = genres
			self.errorOccured = errorOccured
			self.isFetching = isFetching
			self.isPresentingMovieList = isPresentingMovieList
		}
		
		public static let initial: Self = .init(
			genres: [],
			errorOccured: false
		)
		
		// MARK: - MOCKS
		#if DEBUG
		public static let mockErrorOccured: Self = .init(
			genres: [],
			errorOccured: true,
			isFetching: false,
			isPresentingMovieList: false
		)
		
		public static let mockSuccessfullyFetched: Self = .init(
			genres: [.mock],
			errorOccured: false,
			isFetching: false,
			isPresentingMovieList: false
		)
		
		public static let mockTappedItem: Self = .init(
			genres: [.mock],
			errorOccured: false,
			isFetching: false,
			isPresentingMovieList: true
		)
		#endif
	}
	
	// MARK: - Actions
	public enum Action: Equatable {
		case onAppear
		
		case loadGenreList
		case genreListLoaded(GenreList.State)
		case genreListItem(id: GenreListItem.State.ID, action: GenreListItem.Action)
		
		case movieListView(MovieList.Action)
		
		case setNavigation(isActive: Bool)
	}
	
	// MARK: Dependencies
	@Dependency(\.genreList) var env
	// MARK: - Reducer
	public var body: some Reducer<State, Action> {
		Scope(
			state: \.movieList,
			action: \.movieListView
		) {
			MovieList()
		}
		Reduce { state, action in
			switch action {
			case .onAppear:
				return .send(.loadGenreList)
			case .loadGenreList:
				state.isPresentingMovieList = false
				state.movieList = .empty
				return .run { send in
					let list = try await env.loadGenresList()
					await send(.genreListLoaded(list))
				}
			case .genreListLoaded(let genreState):
				state = genreState
				state.isFetching = false
				return .none
			case .genreListItem(id: let id, action: _):
				state.movieList = .init(
					id: id,
					genreTitle: state.genres[id: id]?.name ?? "",
					items: [],
					totalPages: 1000,
					errorOccured: false
				)
				state.isPresentingMovieList = true
				return .none
			case .movieListView:
				return .none
			case .setNavigation(isActive: let isActive):
				state.isPresentingMovieList = isActive
				return .none
			}
		}
	}
	// MARK: Init
	public init() {}
}

// MARK: - Environment
public struct GenreListEnvironment {
	var loadGenresList: @Sendable () async throws -> GenreList.State
	
	public init(
		loadGenresList: @escaping @Sendable () async throws -> GenreList.State
	) {
		self.loadGenresList = loadGenresList
	}
}

public extension DependencyValues {
	var genreList: GenreListEnvironment {
		get { self[GenreListKey.self] }
		set { self[GenreListKey.self] = newValue }
	}
	enum GenreListKey: TestDependencyKey {
		public static let testValue: GenreListEnvironment = .init {
			unimplemented("loadGenresList")
		}
#if DEBUG
		public static let previewValue: GenreListEnvironment = .init(
			loadGenresList: { .initial }
		)
#endif
	}
}

// MARK: - View
public struct GenreListView: View {
	
	public init(store: StoreOf<GenreList>) {
		self.store = store
	}
	
	@Bindable
	var store: StoreOf<GenreList>
	
	public var body: some View {
		NavigationStack {
			VStack {
				if store.errorOccured {
					HStack {
						Text(Localization.generalErrorMessage)
							.padding(.leading, 12)
						Spacer()
						Button {
							store.send(.loadGenreList)
						} label: {
							Text(Localization.retryActionTitle)
						}
						.padding(.trailing, 12)
					}
					.frame(maxWidth: .infinity, maxHeight: 50)
					.foregroundColor(Color.white)
					.background(Color.red)
				}
				if store.isFetching {
					ProgressView()
				} else {
					List {
						ForEachStore(
							store.scope(
								state: \.genres,
								action: \.genreListItem
							),
							content: GenreListItemView.init(store:)
						)
					}
				}
			}
			.navigationDestination(
				isPresented: $store.isPresentingMovieList.sending(\.setNavigation),
				destination: {
					MovieListView(
						store: store.scope(
							state: \.movieList,
							action: \.movieListView
						)
					)
				}
			)
		}
		.navigationTitle(Localization.navigationBarTitle)
		.navigationViewStyle(StackNavigationViewStyle())
		.task {
			await store.send(.onAppear).finish()
		}
	}
}

#if DEBUG
// MARK: - Previews
#Preview {
	GenreListView(
		store: .init(
			initialState: .mockSuccessfullyFetched,
			reducer: GenreList.init
		)
	)
}

public extension GenreListEnvironment {
	
	static func mockErrorOccured(
	) -> Self {
		.init(
			loadGenresList: { .mockErrorOccured }
		)
	}
	
	static func mockSuccessfullyFetched(
	) -> Self {
		.init(
			loadGenresList: { .mockSuccessfullyFetched }
		)
	}
}
#endif
