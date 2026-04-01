import SwiftUI

struct MatchesListView: View {
    @State private var matches: [Match] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.purple.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading && matches.isEmpty {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await loadMatches() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if matches.isEmpty {
                    VStack(spacing: 20) {
                        Text("💬")
                            .font(.system(size: 80))
                        Text("No Matches Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Start swiping to find your matches!")
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(matches) { match in
                            MatchRowView(match: match)
                                .listRowBackground(Color.clear)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .onTapGesture {
                                    // Navigate to chat - will integrate Stream Chat later
                                }
                        }
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await loadMatches()
                    }
                }
            }
            .navigationTitle("Matches")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await loadMatches() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.pink)
                    }
                    .disabled(isLoading)
                }
            }
        }
        .task {
            if matches.isEmpty {
                await loadMatches()
            }
        }
    }
    
    private func loadMatches() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIClient.shared.getMatches()
            matches = response.matches
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
}

struct MatchRowView: View {
    let match: Match
    
    var body: some View {
        HStack(spacing: 16) {
            if let photoUrl = match.matchedUser.photos.first {
                AsyncImage(url: URL(string: photoUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else {
                        Color.gray
                    }
                }
                .frame(width: 70, height: 70)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 2))
            } else {
                Circle()
                    .fill(Color.gray)
                    .frame(width: 70, height: 70)
                    .overlay {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                            .font(.title)
                    }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(match.matchedUser.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    if match.matchedUser.isVerified {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.caption)
                    }
                }
                
                if let lastMessage = match.lastMessage {
                    Text(lastMessage)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else {
                    Text("Say hi to \(match.matchedUser.name)!")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                }
                
                Text(match.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 8) {
                if match.unreadCount > 0 {
                    Text("\(match.unreadCount)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(
                            LinearGradient(
                                colors: [.pink, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
