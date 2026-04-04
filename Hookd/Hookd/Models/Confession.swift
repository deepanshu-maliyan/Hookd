import Foundation

struct Confession: Codable, Identifiable {
    let id: String
    let body: String
    let imageUrl: String?
    let upvotes: Int
    let commentCount: Int
    let createdAt: String
    let isAnonymous: Bool
    let hasUpvoted: Bool?
    
    var timeAgo: String {
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else { return "" }
        
        let now = Date()
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .weekOfYear], from: date, to: now)
        
        if let week = components.weekOfYear, week > 0 {
            return "\(week)w ago"
        } else if let day = components.day, day > 0 {
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

struct ConfessionsResponse: Codable {
    let confessions: [Confession]
    let hasMore: Bool
}

struct CreateConfessionRequest: Codable {
    let body: String
    let imageUrl: String?
    let isAnonymous: Bool
}
