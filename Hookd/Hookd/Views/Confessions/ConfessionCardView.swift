import SwiftUI

struct ConfessionCardView: View {
    let confession: Confession
    @State private var hasUpvoted: Bool
    @State private var upvoteCount: Int
    
    init(confession: Confession) {
        self.confession = confession
        self._hasUpvoted = State(initialValue: confession.hasUpvoted ?? false)
        self._upvoteCount = State(initialValue: confession.upvotes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                if confession.isAnonymous {
                    HStack(spacing: 6) {
                        Image(systemName: "theatermasks.fill")
                            .font(.caption)
                        Text("Anonymous")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
                
                Text(confession.timeAgo)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(confession.body)
                .font(.body)
                .foregroundColor(.primary)
                .fixedSize(horizontal: false, vertical: true)
            
            if let imageUrl = confession.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .scaledToFill()
                    } else if phase.error != nil {
                        Color.gray.opacity(0.3)
                    } else {
                        ProgressView()
                    }
                }
                .frame(height: 200)
                .cornerRadius(12)
                .clipped()
            }
            
            HStack(spacing: 20) {
                Button(action: handleUpvote) {
                    HStack(spacing: 6) {
                        Image(systemName: hasUpvoted ? "arrow.up.circle.fill" : "arrow.up.circle")
                            .font(.title3)
                        Text("\(upvoteCount)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(hasUpvoted ? .orange : .secondary)
                }
                
                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .font(.title3)
                    Text("\(confession.commentCount)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundColor(.secondary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func handleUpvote() {
        withAnimation(.spring(response: 0.3)) {
            if hasUpvoted {
                upvoteCount -= 1
            } else {
                upvoteCount += 1
            }
            hasUpvoted.toggle()
        }
    }
}
