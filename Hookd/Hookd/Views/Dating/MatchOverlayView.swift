import SwiftUI

struct MatchOverlayView: View {
    let match: Match
    @Binding var isPresented: Bool
    @State private var showAnimation = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                Text("It's a Match!")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.pink, .purple, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .scaleEffect(showAnimation ? 1.0 : 0.5)
                    .opacity(showAnimation ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: showAnimation)
                
                Text("You and \(match.matchedUser.name) liked each other!")
                    .font(.title3)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(showAnimation ? 1.0 : 0.0)
                    .animation(.easeIn.delay(0.5), value: showAnimation)
                
                HStack(spacing: -30) {
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
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                        
                        Image(systemName: "heart.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                    }
                    .scaleEffect(showAnimation ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.8), value: showAnimation)
                    .zIndex(1)
                }
                .scaleEffect(showAnimation ? 1.0 : 0.8)
                .opacity(showAnimation ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: showAnimation)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Send Message")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                LinearGradient(
                                    colors: [.pink, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                    }
                    
                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Keep Swiping")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                .opacity(showAnimation ? 1.0 : 0.0)
                .animation(.easeIn.delay(1.0), value: showAnimation)
            }
            
            if showAnimation {
                ForEach(0..<20) { _ in
                    Text(["💘", "💖", "💗", "✨", "💫"].randomElement()!)
                        .font(.system(size: 40))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                        .opacity(0.7)
                }
                .transition(.scale.combined(with: .opacity))
                .animation(.easeOut(duration: 2.0), value: showAnimation)
            }
        }
        .onAppear {
            showAnimation = true
        }
    }
}
