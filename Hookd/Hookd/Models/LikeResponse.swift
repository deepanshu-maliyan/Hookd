import Foundation

struct LikeResponse: Codable {
    let isMatch: Bool
    let match: Match?
}

struct LikeRequest: Codable {
    let targetUserId: String
}

struct DiscoveryResponse: Codable {
    let users: [User]
}
