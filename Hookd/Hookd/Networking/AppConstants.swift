import Foundation

enum AppConstants {
    static let backendBaseURL = "http://localhost:3000/api/v1"
    static let streamAPIKey = "yd5k9k5jhufh"
    
    enum Endpoints {
        static let register = "/auth/register"
        static let login = "/auth/login"
        static let streamToken = "/auth/stream-token"
        static let me = "/users/me"
        static let discovery = "/dating/discovery"
        static let like = "/dating/like"
        static let matches = "/dating/matches"
        static let confessions = "/confessions"
        static let presignedUrl = "/upload/presigned-url"
    }
}
