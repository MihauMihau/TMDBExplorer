import Combine
import ComposableArchitecture

public protocol APIProviderType {
	func getGenres() async throws -> GenreListModel?
	func fetchMovies(for genreId: Int, page: Int) async throws -> MovieListModel?
}
