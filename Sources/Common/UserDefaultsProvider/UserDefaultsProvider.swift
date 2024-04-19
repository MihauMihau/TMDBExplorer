import Foundation

final class UserDefaultsProvider {
	
	private enum Contants {
		static let genreListKey = "genreList"
		static let fetchDateKey = "fetchDate"
	}
	
	static func storeGenreList(genreList: GenreListModel) {
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(genreList)
			UserDefaults.standard.set(data, forKey: Contants.genreListKey)
		} catch {
			print("Unable to encode GenreList (\(error))")
		}
	}
	
	static func getGenreList() -> GenreListModel? {
		if let data = UserDefaults.standard.data(forKey: Contants.genreListKey) {
			do {
				let decoder = JSONDecoder()
				let genreList = try decoder.decode(GenreListModel.self, from: data)
				return genreList
			} catch {
				print("Unable to decode GenreList (\(error))")
			}
		}
		return nil
	}
	
	static func storeFetchDate(date: Date) {
		do {
			let encoder = JSONEncoder()
			let data = try encoder.encode(date)
			UserDefaults.standard.set(data, forKey: Contants.fetchDateKey)
		} catch {
			print("Unable to encode Date (\(error))")
		}
	}
	
	static func getFetchDate() -> Date? {
		if let data = UserDefaults.standard.data(forKey: Contants.fetchDateKey) {
			do {
				let decoder = JSONDecoder()
				let fetchDate = try decoder.decode(Date.self, from: data)
				return fetchDate
			} catch {
				print("Unable to decode Date (\(error))")
			}
		}
		return nil
	}
	
}
