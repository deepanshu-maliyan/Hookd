import Foundation

enum AppConstants {
    static let backendBaseURL = "http://localhost:3000/api/v1"
    static let streamAPIKey = "yd5k9k5jhufh"
    
    enum Endpoints {
        static let register = "/auth/register"
        static let login = "/auth/login"
        static let streamToken = "/stream/token"
        static let me = "/users/me"
        static let discovery = "/matching/discovery"
        static let like = "/matching/like"
        static let matches = "/matching/matches"
        static let confessions = "/confessions"
        static let presignedUrl = "/media/presigned-url"
    }
}
