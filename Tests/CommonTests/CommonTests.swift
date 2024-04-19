import ComposableArchitecture
import XCTest
@testable import Common

final class CommonTests: XCTestCase {
	
	func test_cacheDeterminerExactTime() {
		let refetchThreshold: TimeInterval = 24 * 60 * 60
		let fetchDate = Date().addingTimeInterval(-refetchThreshold)
		
		XCTAssertTrue(
			CacheDeterminer.shouldRefetch(
				fetchDate: fetchDate,
				refetchThreshold: refetchThreshold
			)
		)
	}
	
	func test_cacheDeterminerSecondAfter() {
		let refetchThreshold: TimeInterval = 24 * 60 * 60
		let fetchDate = Date().addingTimeInterval(-refetchThreshold - 1)
		
		XCTAssertTrue(
			CacheDeterminer.shouldRefetch(
				fetchDate: fetchDate,
				refetchThreshold: refetchThreshold
			)
		)
	}
	
	func test_cacheDeterminerSecondBefore() {
		let refetchThreshold: TimeInterval = 24 * 60 * 60
		let fetchDate = Date().addingTimeInterval(-refetchThreshold + 1)
		
		XCTAssertFalse(
			CacheDeterminer.shouldRefetch(
				fetchDate: fetchDate,
				refetchThreshold: refetchThreshold
			)
		)
	}
}
