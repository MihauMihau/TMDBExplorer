// swift-tools-version:5.9

import PackageDescription

let package = Package(
	name: "TMDBExplorer",
	platforms: [
		.iOS(.v17),
	],
	products: [
		.library(
			name: "Common",
			targets: [
				"Common",
			]
		),
		.library(
			name: "Localization",
			targets: [
				"Localization",
			]
		),
		.library(
			name: "GenreListFeature",
			targets: [
				"GenreListFeature",
			]
		),
		.library(
			name: "MovieListFeature",
			targets: [
				"MovieListFeature",
			]
		),
	],
	dependencies: [
		.package(
			url: "https://github.com/pointfreeco/swift-composable-architecture.git",
			from: "1.9.3"
		),
		.package(
			url: "https://github.com/kean/NukeUI.git",
			from: "0.8.3"
		),
	],
	targets: [
		.target(
			name: "Common",
			dependencies: [
				"MovieListFeature",
				"GenreListFeature",
				.product(
					name: "ComposableArchitecture",
					package: "swift-composable-architecture"
				),
			]
		),
		.testTarget(
			name: "CommonTests",
			dependencies: [
				"Common"
			]
		),
		.target(
			name: "GenreListFeature",
			dependencies: [
				"MovieListFeature",
				"Localization",
				.product(
					name: "ComposableArchitecture",
					package: "swift-composable-architecture"
				)
			]
		),
		.testTarget(
			name: "GenreListFeatureTests",
			dependencies: [
				"GenreListFeature"
			]
		),
		.target(
			name: "MovieListFeature",
			dependencies: [
				"Localization",
				.product(
					name: "ComposableArchitecture",
					package: "swift-composable-architecture"
				),
				.product(
					name: "NukeUI",
					package: "NukeUI"
				),
			]
		),
		.testTarget(
			name: "MovieListFeatureTests",
			dependencies: [
				"MovieListFeature"
			]
		),
		.target(
			name: "Localization",
			dependencies: []
		),
	]
)
