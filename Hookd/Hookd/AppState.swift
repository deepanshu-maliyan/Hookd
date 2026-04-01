import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var onboardingStep: OnboardingStep = .intent
    @Published var needsOnboarding = false
    
    private let apiClient = APIClient.shared
    
    enum OnboardingStep {
        case intent
        case tags
        case photos
        case complete
    }
    
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
    
    func loadCurrentUser() async {
        do {
            currentUser = try await apiClient.getMe()
            isAuthenticated = true
            checkOnboardingStatus()
        } catch {
            try? KeychainHelper.deleteToken()
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    func login(email: String, password: String) async throws {
        let response = try await apiClient.login(email: email, password: password)
        try KeychainHelper.saveToken(response.token)
        currentUser = response.user
        isAuthenticated = true
        checkOnboardingStatus()
    }
    
    func register(email: String, password: String, name: String, age: Int, gender: String) async throws {
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
        needsOnboarding = true
        onboardingStep = .intent
    }
    
    func logout() {
        try? KeychainHelper.deleteToken()
        isAuthenticated = false
        currentUser = nil
        needsOnboarding = false
        onboardingStep = .intent
    }
    
    func updateUser(_ user: User) {
        currentUser = user
        checkOnboardingStatus()
    }
    
    func completeOnboardingStep() {
        switch onboardingStep {
        case .intent:
            onboardingStep = .tags
        case .tags:
            onboardingStep = .photos
        case .photos:
            onboardingStep = .complete
            needsOnboarding = false
        case .complete:
            needsOnboarding = false
        }
    }
    
    private func checkOnboardingStatus() {
        guard let user = currentUser else {
            needsOnboarding = false
            return
        }
        
        if user.intent.isEmpty {
            needsOnboarding = true
            onboardingStep = .intent
        } else if user.fantasyTags.isEmpty {
            needsOnboarding = true
            onboardingStep = .tags
        } else if user.photos.count < 2 {
            needsOnboarding = true
            onboardingStep = .photos
        } else {
            needsOnboarding = false
            onboardingStep = .complete
        }
    }
}
