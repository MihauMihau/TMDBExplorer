import Foundation
import ComposableArchitecture

final class CacheDeterminer {
	
	static func shouldRefetch(
		fetchDate: Date,
		refetchThreshold: TimeInterval
	) -> Bool {
		
		let now = Date()
		let refetchDate = fetchDate.addingTimeInterval(refetchThreshold)
		
		let range = fetchDate...refetchDate
		
		return !range.contains(now)
	}
}
