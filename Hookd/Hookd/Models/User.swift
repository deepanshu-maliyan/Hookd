import Foundation

struct User: Codable, Identifiable {
    let id: String
    var email: String
    var name: String
    var bio: String?
    var age: Int
    var gender: String
    var intent: String?
    var fantasyTags: [String]?
    var photos: [String]?
    var isVerified: Bool?
    var streamUserId: String?
    
    enum CodingKeys: String, CodingKey {
        case id, email, name, bio, age, gender, intent
        case fantasyTags, photos, isVerified, streamUserId
    }
    
    var displayName: String {
        "\(name), \(age)"
    }
    
    var intentDisplay: String {
        guard let intent = intent else { return "Not set" }
        switch intent {
        case "serious": return "Serious Relationship"
        case "casual": return "Casual Dating"
        case "hookup": return "Hookup"
        case "fwb": return "Friends with Benefits"
        case "explore": return "Exploring"
        default: return intent.capitalized
        }
    }
    
    var intentColor: String {
        guard let intent = intent else { return "gray" }
        switch intent {
        case "serious": return "blue"
        case "casual": return "green"
        case "hookup": return "red"
        case "fwb": return "orange"
        case "explore": return "purple"
        default: return "gray"
        }
    }
}
