import Foundation
import SwiftUI

@MainActor
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiClient = APIClient.shared
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let _ = try? KeychainHelper.loadToken() {
            Task {
                await loadCurrentUser()
            }
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.login(email: email, password: password)
            try KeychainHelper.saveToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
    
    func register(email: String, password: String, name: String, age: Int, gender: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiClient.register(
                email: email,
                password: password,
                name: name,
                age: age,
                gender: gender
            )
            try KeychainHelper.saveToken(response.token)
            currentUser = response.user
            isAuthenticated = true
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadCurrentUser() async {
        do {
            currentUser = try await apiClient.getMe()
            isAuthenticated = true
        } catch {
            try? KeychainHelper.deleteToken()
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func logout() {
        try? KeychainHelper.deleteToken()
        isAuthenticated = false
        currentUser = nil
    }
    
    func updateUser(_ user: User) {
        currentUser = user
    }
}
