import Foundation

struct Match: Codable, Identifiable {
    let id: String
    let userId: String
    let matchedUserId: String
    let matchedUser: User
    let createdAt: String
    let lastMessage: String?
    let lastMessageAt: String?
    let unreadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case matchedUserId = "matched_user_id"
        case matchedUser = "matched_user"
        case createdAt = "created_at"
        case lastMessage = "last_message"
        case lastMessageAt = "last_message_at"
        case unreadCount = "unread_count"
    }
    
    var timeAgo: String {
        guard let lastMessageAt = lastMessageAt else { return "Just matched" }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: lastMessageAt) else { return "" }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 0 {
            return "\(day)d ago"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)h ago"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)m ago"
        } else {
            return "Just now"
        }
    }
}

struct MatchesResponse: Codable {
    let matches: [Match]
}
