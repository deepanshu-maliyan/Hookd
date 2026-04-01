import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case unauthorized
    case serverError(Int, String?)
    case decodingError(Error)
    case encodingError(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .serverError(let code, let message):
            return message ?? "Server error (\(code))"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Failed to encode request: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

class APIClient {
    static let shared = APIClient()
    private let baseURL = AppConstants.backendBaseURL
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    
    private init() {
        decoder = JSONDecoder()
        encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
    }
    
    private func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requiresAuth {
            if let token = try? KeychainHelper.loadToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decodingError(error)
            }
        case 401:
            throw APIError.unauthorized
        case 400...599:
            let message = try? JSONDecoder().decode([String: String].self, from: data)
            throw APIError.serverError(httpResponse.statusCode, message?["error"] ?? message?["message"])
        default:
            throw APIError.unknown
        }
    }
    
    func register(email: String, password: String, name: String, age: Int, gender: String) async throws -> AuthResponse {
        let body = RegisterRequest(email: email, password: password, name: name, age: age, gender: gender)
        return try await request(
            endpoint: AppConstants.Endpoints.register,
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }
    
    func login(email: String, password: String) async throws -> AuthResponse {
        let body = LoginRequest(email: email, password: password)
        return try await request(
            endpoint: AppConstants.Endpoints.login,
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }
    
    func getStreamToken() async throws -> StreamTokenResponse {
        return try await request(endpoint: AppConstants.Endpoints.streamToken)
    }
    
    func getMe() async throws -> User {
        return try await request(endpoint: AppConstants.Endpoints.me)
    }
    
    func updateProfile(bio: String?, intent: String?, fantasyTags: [String]?, photos: [String]?) async throws -> User {
        let body = UpdateProfileRequest(bio: bio, intent: intent, fantasyTags: fantasyTags, photos: photos)
        return try await request(
            endpoint: AppConstants.Endpoints.me,
            method: "PATCH",
            body: body
        )
    }
    
    func likeUser(targetUserId: String) async throws -> LikeResponse {
        let body = LikeRequest(targetUserId: targetUserId)
        return try await request(
            endpoint: AppConstants.Endpoints.like,
            method: "POST",
            body: body
        )
    }
    
    func getMatches() async throws -> MatchesResponse {
        return try await request(endpoint: AppConstants.Endpoints.matches)
    }
    
    func getDiscovery() async throws -> DiscoveryResponse {
        return try await request(endpoint: AppConstants.Endpoints.discovery)
    }
    
    func createConfession(body: String, imageUrl: String?, isAnonymous: Bool) async throws -> Confession {
        let requestBody = CreateConfessionRequest(body: body, imageUrl: imageUrl, isAnonymous: isAnonymous)
        return try await request(
            endpoint: AppConstants.Endpoints.confessions,
            method: "POST",
            body: requestBody
        )
    }
    
    func getConfessions(page: Int = 1, limit: Int = 20) async throws -> ConfessionsResponse {
        let endpoint = "\(AppConstants.Endpoints.confessions)?page=\(page)&limit=\(limit)"
        return try await request(endpoint: endpoint)
    }
    
    func getPresignedUrl(filename: String, contentType: String) async throws -> PresignedUrlResponse {
        let endpoint = "\(AppConstants.Endpoints.presignedUrl)?filename=\(filename)&contentType=\(contentType)"
        return try await request(endpoint: endpoint)
    }
    
    func uploadToPresignedUrl(url: String, data: Data, contentType: String) async throws {
        guard let uploadURL = URL(string: url) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: uploadURL)
        request.httpMethod = "PUT"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = data
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }
}
