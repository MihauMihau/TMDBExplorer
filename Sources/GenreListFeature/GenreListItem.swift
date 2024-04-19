import ComposableArchitecture
import SwiftUI

// MARK: - Reducer
@Reducer
public struct GenreListItem {
	// MARK: - State
	@ObservableState
	public struct State: Equatable, Identifiable {
		public var id: Int
		public var name: String
		
		public init(
			id: Int,
			name: String
		) {
			self.id = id
			self.name = name
		}
		
		#if DEBUG
		// MARK: State Mock
		static let mock: Self = .init(
			id: 1,
			name: "Action"
		)
		#endif
	}
	
	// MARK: - Action
	public enum Action: Equatable {
		case didTapItem
	}
}

// MARK: - View
struct GenreListItemView: View {
	
	let store: StoreOf<GenreListItem>
	
	public init(store: StoreOf<GenreListItem>) {
		self.store = store
	}
	
	var body: some View {
		HStack {
			Text(store.name)
			Spacer()
		}
		.contentShape(Rectangle())
		.onTapGesture {
			store.send(.didTapItem)
		}
	}
}

#if DEBUG
// MARK: - Previews
#Preview {
	GenreListItemView(
		store: .init(
			initialState: .mock,
			reducer: GenreListItem.init
		)
	)
}
#endif
