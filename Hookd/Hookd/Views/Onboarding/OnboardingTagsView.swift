import SwiftUI

struct OnboardingTagsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTags: Set<String> = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    let allTags = [
        "threesome", "fwb", "bdsm", "voyeur", "open-relationship",
        "casual", "no-labels", "poly", "roleplay", "vanilla",
        "older-partner", "younger-partner", "exhibitionist", "queer", "long-distance"
    ]
    
    let columns = [
        GridItem(.adaptive(minimum: 100), spacing: 12)
    ]
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.pink.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 25) {
                VStack(spacing: 12) {
                    Text("🔥")
                        .font(.system(size: 60))
                    
                    Text("Your Vibe Check")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                    
                    Text("Pick 1-10 tags that describe what you're into. Be yourself!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 60)
                
                Text("\(selectedTags.count)/10 selected")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(selectedTags.isEmpty ? .red : (selectedTags.count > 10 ? .red : .green))
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(allTags, id: \.self) { tag in
                            TagPill(
                                tag: tag,
                                isSelected: selectedTags.contains(tag)
                            ) {
                                toggleTag(tag)
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
                            colors: [.purple, .pink],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                .disabled(!isSelectionValid || isLoading)
                .opacity((!isSelectionValid || isLoading) ? 0.6 : 1.0)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
    }
    
    private var isSelectionValid: Bool {
        selectedTags.count >= 1 && selectedTags.count <= 10
    }
    
    private func toggleTag(_ tag: String) {
        if selectedTags.contains(tag) {
            selectedTags.remove(tag)
        } else {
            if selectedTags.count < 10 {
                selectedTags.insert(tag)
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
                    intent: nil,
                    fantasyTags: Array(selectedTags),
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

struct TagPill: View {
    let tag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(displayTag)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    isSelected ?
                    LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing) :
                    LinearGradient(colors: [Color(.systemGray6)], startPoint: .leading, endPoint: .trailing)
                )
                .cornerRadius(20)
                .shadow(color: isSelected ? .purple.opacity(0.3) : .clear, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.spring(response: 0.3), value: isSelected)
    }
    
    private var displayTag: String {
        tag.replacingOccurrences(of: "-", with: " ")
            .split(separator: " ")
            .map { $0.capitalized }
            .joined(separator: " ")
    }
}
