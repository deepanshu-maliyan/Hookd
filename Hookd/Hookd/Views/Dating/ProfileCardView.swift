import SwiftUI

struct ProfileCardView: View {
    let user: User
    @State private var currentPhotoIndex = 0
    
    private var photos: [String] {
        user.photos ?? []
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                if photos.isEmpty {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [.gray.opacity(0.3), .gray.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .overlay {
                            VStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundColor(.white)
                                Text("No Photo")
                                    .foregroundColor(.white)
                            }
                        }
                } else {
                    TabView(selection: $currentPhotoIndex) {
                        ForEach(Array(photos.enumerated()), id: \.offset) { index, photoUrl in
                            AsyncImage(url: URL(string: photoUrl)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                case .failure:
                                    Image(systemName: "photo")
                                        .font(.system(size: 60))
                                        .foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
                
                if photos.count > 1 {
                    HStack(spacing: 4) {
                        ForEach(0..<photos.count, id: \.self) { index in
                            Capsule()
                                .fill(currentPhotoIndex == index ? Color.white : Color.white.opacity(0.5))
                                .frame(width: currentPhotoIndex == index ? 20 : 8, height: 4)
                        }
                    }
                    .padding(.top, 8)
                    .frame(maxWidth: .infinity, alignment: .top)
                }
                
                LinearGradient(
                    colors: [.clear, .black.opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(user.displayName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                            
                            HStack {
                                Text(user.intentDisplay)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(intentColor)
                                    .cornerRadius(12)
                                
                                if user.isVerified == true {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    
                    if let bio = user.bio, !bio.isEmpty {
                        Text(bio)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                            .lineLimit(3)
                    }
                    
                    if let tags = user.fantasyTags, !tags.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag.replacingOccurrences(of: "-", with: " ").capitalized)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                        .background(Color.white.opacity(0.2))
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
    
    private var intentColor: Color {
        switch user.intent ?? "" {
        case "serious": return .blue
        case "casual": return .green
        case "hookup": return .red
        case "fwb": return .orange
        case "explore": return Color(red: 1.0, green: 0.5, blue: 0)
        default: return .gray
        }
    }
}
