import Foundation

struct AuthResponse: Codable {
    let token: String
    let user: User
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let name: String
    let age: Int
    let gender: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
        case name
        case age
        case gender
    }
}
