// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RxHubConnection",
    products: [
        .library(
            name: "RxHubConnection",
            targets: ["RxHubConnection"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git"),
        
        .package(url: "https://github.com/moozzyk/SignalR-Client-Swift.git")
       
    ],
    targets: [
        .target(
            name: "RxHubConnection",
            dependencies: [
                .product(name: "SignalRClient", package: "SignalR-Client-Swift"),
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift")
            ],
            path: "RxHubConnection/Classes")
    ]
)
