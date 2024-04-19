public struct MovieModel: Decodable, Identifiable {
	public let id: Int
	public let title: String
	public let posterPath: String
	
	private enum CodingKeys: String, CodingKey {
		case posterPath = "poster_path"
		case id, title
	}
}
