import Foundation

struct PresignedUrlResponse: Codable {
    let uploadUrl: String
    let cdnUrl: String
    
    enum CodingKeys: String, CodingKey {
        case uploadUrl = "upload_url"
        case cdnUrl = "cdn_url"
    }
}

struct UpdateProfileRequest: Codable {
    let bio: String?
    let intent: String?
    let fantasyTags: [String]?
    let photos: [String]?
    
    enum CodingKeys: String, CodingKey {
        case bio
        case intent
        case fantasyTags = "fantasy_tags"
        case photos
    }
}

struct StreamTokenResponse: Codable {
    let token: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case token
        case userId = "user_id"
    }
}
