import SwiftUI

struct ConfessionsListView: View {
    @State private var confessions: [Confession] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showPostSheet = false
    @State private var currentPage = 1
    @State private var hasMore = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.orange.opacity(0.1), Color.pink.opacity(0.1)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if isLoading && confessions.isEmpty {
                    ProgressView()
                } else if let errorMessage = errorMessage {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.red)
                        Text(errorMessage)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await loadConfessions() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                } else if confessions.isEmpty {
                    VStack(spacing: 20) {
                        Text("🤫")
                            .font(.system(size: 80))
                        Text("No Confessions Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Be the first to share something!")
                            .foregroundColor(.secondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(confessions) { confession in
                                ConfessionCardView(confession: confession)
                            }
                            
                            if hasMore {
                                ProgressView()
                                    .onAppear {
                                        Task { await loadMore() }
                                    }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        currentPage = 1
                        await loadConfessions()
                    }
                }
            }
            .navigationTitle("Confessions")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPostSheet = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.pink, .orange],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            }
            .sheet(isPresented: $showPostSheet) {
                PostConfessionView(onPost: { newConfession in
                    confessions.insert(newConfession, at: 0)
                })
            }
        }
        .task {
            if confessions.isEmpty {
                await loadConfessions()
            }
        }
    }
    
    private func loadConfessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIClient.shared.getConfessions(page: 1, limit: 20)
            confessions = response.confessions
            hasMore = response.hasMore
            currentPage = 1
        } catch {
            errorMessage = (error as? APIError)?.errorDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func loadMore() async {
        guard !isLoading && hasMore else { return }
        
        isLoading = true
        
        do {
            let nextPage = currentPage + 1
            let response = try await APIClient.shared.getConfessions(page: nextPage, limit: 20)
            confessions.append(contentsOf: response.confessions)
            hasMore = response.hasMore
            currentPage = nextPage
        } catch {
            print("Load more error: \(error)")
        }
        
        isLoading = false
    }
}
