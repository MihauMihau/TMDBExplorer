public struct MovieListModel: Decodable {
	var page: Int
	var totalPages: Int
	var results: [MovieModel]
	
	private enum CodingKeys: String, CodingKey {
		case totalPages = "total_pages"
		case page, results
	}
}
