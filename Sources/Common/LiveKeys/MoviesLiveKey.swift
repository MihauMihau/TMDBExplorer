import ComposableArchitecture
import MovieListFeature

private enum Constants {
	static let imagePath = "https://image.tmdb.org/t/p/w154"
}

extension DependencyValues.MovieListKey: DependencyKey {
	public static var liveValue: MovieListEnvironment = .init { id, name, page in
		do {
			return try await apiProvider.fetchMovies(
				for: id,
				page: page
			)
			.map { movieList in
				return MovieList.State(
					id: id,
					genreTitle: name,
					items: IdentifiedArrayOf(
						uniqueElements: movieList
							.results
							.map {
								MovieListItem.State(
									id: $0.id,
									name: $0.title,
									imagePath: "\(Constants.imagePath)\($0.posterPath)"
								)
							}
					),
					totalPages: movieList.totalPages,
					errorOccured: false
				)
			}
			??
			MovieList.State(
				id: -1,
				genreTitle: name,
				items: [],
				totalPages: 1000,
				errorOccured: true
			)
		} catch {
			return MovieList.State(
				id: -1,
				genreTitle: name,
				items: [],
				totalPages: 1000,
				errorOccured: true
			)
		}
	}
}

