import ComposableArchitecture
import GenreListFeature

extension DependencyValues.GenreListKey: DependencyKey {
	public static var liveValue: GenreListEnvironment = .init {
		do {
			return try await apiProvider.getGenres()
				.map { genreList in
					return GenreList.State(
						genres:  IdentifiedArrayOf(
							uniqueElements: genreList
								.genres
								.map {
									GenreListItem.State.init(
										id: $0.id,
										name: $0.name
									)
								}
						),
						errorOccured: false
					)
				}
			??
			GenreList.State(
				genres: .init(),
				errorOccured: true
			)
		} catch {
			return GenreList.State(
				genres: .init(),
				errorOccured: true
			)
		}
	}
}
