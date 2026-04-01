import Foundation

struct LikeResponse: Codable {
    let isMatch: Bool
    let match: Match?
    
    enum CodingKeys: String, CodingKey {
        case isMatch = "is_match"
        case match
    }
}

struct LikeRequest: Codable {
    let targetUserId: String
    
    enum CodingKeys: String, CodingKey {
        case targetUserId = "target_user_id"
    }
}

struct DiscoveryResponse: Codable {
    let users: [User]
}
