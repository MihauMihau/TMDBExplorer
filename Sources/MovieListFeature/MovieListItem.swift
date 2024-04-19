import ComposableArchitecture
import SwiftUI
import NukeUI

// MARK: - Reducer
@Reducer
public struct MovieListItem {
	// MARK: - State
	@ObservableState
	public struct State: Equatable, Identifiable {
		public var id: Int
		public var name: String
		public var imagePath: String
		
		public init(
			id: Int,
			name: String,
			imagePath: String
		) {
			self.id = id
			self.name = name
			self.imagePath = imagePath
		}
		
		#if DEBUG
		// MARK: Mock
		public static let mock: Self = .init(
			id: 1,
			name: "The Lord of the Rings",
			imagePath: "The Lord of the Images"
		)
		#endif
	}
	
	// MARK: - Action
	public enum Action: Equatable {
		case onAppear
		case didTapItem
	}
}

// MARK: - View
public struct MovieListItemView: View {
	let store: StoreOf<MovieListItem>
	
	public init(store: StoreOf<MovieListItem>) {
		self.store = store
	}
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.verticalSizeClass) var verticalSizeClass
	
	public var body: some View {
		HStack(spacing: 4) {
			LazyImage(
				source: store.imagePath,
				content: { (state: LazyImageState) in
					HStack {
						if let image: NukeUI.Image = state.image {
							image
								.resizingMode(.aspectFit)
						}
					}
					.frame(
						minWidth: horizontalSizeClass == .regular && verticalSizeClass == .regular
						? 50
						: 25,
						maxWidth: horizontalSizeClass == .regular && verticalSizeClass == .regular
						? 100
						: 50,
						minHeight: horizontalSizeClass == .regular && verticalSizeClass == .regular
						? 75
						: 50,
						maxHeight: horizontalSizeClass == .regular && verticalSizeClass == .regular
						? 150
						: 100
					)
				}
			)
			Text(store.name)
				.font(.system(.caption))
			Spacer()
		}
		.frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
		.padding([.top, .horizontal], 8)
		.task {
			await store.send(.onAppear).finish()
		}
	}
}

#if DEBUG
// MARK: Preview
#Preview {
	MovieListItemView(
		store: .init(
			initialState: MovieListItem.State.mock,
			reducer: MovieListItem.init
		)
	)
}
#endif
