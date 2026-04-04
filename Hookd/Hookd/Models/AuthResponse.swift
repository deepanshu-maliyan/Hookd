import Foundation

struct AuthResponse: Codable {
    let accessToken: String
    let user: User
    
    // Alias for convenience
    var token: String { accessToken }
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
}
