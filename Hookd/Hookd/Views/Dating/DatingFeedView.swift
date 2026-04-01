import SwiftUI

struct DatingFeedView: View {
    @State private var discoveryUsers: [User] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showMatchOverlay = false
    @State private var currentMatch: Match?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.pink.opacity(0.1), Color.purple.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading && discoveryUsers.isEmpty {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await loadDiscovery() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if discoveryUsers.isEmpty {
                    VStack(spacing: 20) {
                        Text("😴")
                            .font(.system(size: 80))
                        Text("No More Profiles")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Check back later for more matches!")
                            .foregroundColor(.secondary)
                        Button("Refresh") {
                            Task { await loadDiscovery() }
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    CardStackView(
                        users: $discoveryUsers,
                        onMatch: { match in
                            currentMatch = match
                            showMatchOverlay = true
                        }
                    )
                }
            }
            .navigationTitle("Discover")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await loadDiscovery() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.pink)
                    }
                    .disabled(isLoading)
                }
            }
            .fullScreenCover(isPresented: $showMatchOverlay) {
                if let match = currentMatch {
                    MatchOverlayView(match: match, isPresented: $showMatchOverlay)
                }
            }
        }
        .task {
            if discoveryUsers.isEmpty {
                await loadDiscovery()
            }
        }
    }
    
    private func loadDiscovery() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIClient.shared.getDiscovery()
            discoveryUsers = response.users
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
}
