import Foundation
import ComposableArchitecture

public final class APIProvider: APIProviderType {
	
	// MARK: - Initialization
	public init() {}
	
	// MARK: - Genres
	public func getGenres() async throws -> GenreListModel? {
		let refetchThreshold: TimeInterval = 24 * 60 * 60 // 24 hours in seconds
		
		if let fetchDate = UserDefaultsProvider.getFetchDate(),
		   CacheDeterminer.shouldRefetch(
			fetchDate: fetchDate,
			refetchThreshold: refetchThreshold
		   ) {
			do {
				return try await fetchGenres()
			} catch {
				throw APIError.api
			}
		} else {
			guard
				let genres = UserDefaultsProvider.getGenreList()
			else {
				do {
					return try await fetchGenres()
				} catch {
					throw APIError.api
				}
			}
			
			return genres
		}
	}
	
	private func fetchGenres() async throws -> GenreListModel? {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.themoviedb.org"
		components.path = "/3/genre/movie/list"
		components.queryItems = [
			URLQueryItem(name: "api_key", value: "0b1a18e2b899d214aba36f03889b819e"),
		]
		
		guard let
				url = components.url
		else {
			throw APIError.api
		}
		
		let (data, _) = try await URLSession.shared.data(from: url)
		let model = try JSONDecoder().decode(GenreListModel?.self, from: data)
			.map { genreList in
				UserDefaultsProvider.storeFetchDate(date: Date())
				UserDefaultsProvider.storeGenreList(genreList: genreList)
				return genreList
			}
		
		return model
	}
	
	// MARK: - Movies
	public func fetchMovies(
		for genreId: Int,
		page: Int
	) async throws -> MovieListModel? {
		var components = URLComponents()
		components.scheme = "https"
		components.host = "api.themoviedb.org"
		components.path = "/3/discover/movie"
		components.queryItems = [
			URLQueryItem(name: "with_genres", value: "\(genreId)"),
			URLQueryItem(name: "page", value: "\(page)"),
			URLQueryItem(name: "api_key", value: "0b1a18e2b899d214aba36f03889b819e"),
		]
		
		guard let
				url = components.url
		else {
			throw APIError.api
		}
		
		let (data, _) = try await URLSession.shared.data(from: url)
		let model = try JSONDecoder().decode(MovieListModel?.self, from: data)
		return model
	}
}
