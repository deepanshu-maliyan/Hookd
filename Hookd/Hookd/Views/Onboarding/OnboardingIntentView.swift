import SwiftUI

struct OnboardingIntentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedIntent = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let intents: [(value: String, title: String, icon: String, description: String, color: Color)] = [
        ("serious", "Serious Relationship", "heart.circle.fill", "Looking for something real", .blue),
        ("casual", "Casual Dating", "person.2.fill", "Taking it slow", .green),
        ("hookup", "Hookup", "flame.fill", "Just for tonight", .red),
        ("fwb", "Friends with Benefits", "star.fill", "No strings attached", .orange),
        ("explore", "Exploring", "sparkles", "Still figuring it out", .purple)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.pink.opacity(0.2), Color.purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text("🎯")
                        .font(.system(size: 60))
                    
                    Text("What are you looking for?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Be honest. Everyone's here for different reasons.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(intents, id: \.value) { intent in
                            IntentButton(
                                intent: intent,
                                isSelected: selectedIntent == intent.value
                            ) {
                                selectedIntent = intent.value
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: handleContinue) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Continue")
                                .fontWeight(.semibold)
                            Image(systemName: "arrow.right")
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.pink, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .disabled(selectedIntent.isEmpty || isLoading)
                .opacity((selectedIntent.isEmpty || isLoading) ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    private func handleContinue() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let updatedUser = try await APIClient.shared.updateProfile(
                    bio: nil,
                    intent: selectedIntent,
                    fantasyTags: nil,
                    photos: nil
                )
                appState.updateUser(updatedUser)
                appState.completeOnboardingStep()
            } catch {
                errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
            }
            isLoading = false
        }
    }
}

struct IntentButton: View {
    let intent: (value: String, title: String, icon: String, description: String, color: Color)
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: intent.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : intent.color)
                    .frame(width: 50, height: 50)
                    .background(isSelected ? intent.color : intent.color.opacity(0.2))
                    .cornerRadius(12)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(intent.title)
                        .font(.headline)
                        .foregroundColor(isSelected ? .white : .primary)
                    
                    Text(intent.description)
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.9) : .secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(isSelected ? intent.color : Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: isSelected ? intent.color.opacity(0.3) : .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
