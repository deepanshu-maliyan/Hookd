import SwiftUI

struct CardStackView: View {
    @Binding var users: [User]
    let onMatch: (Match) -> Void
    
    @State private var dragAmount = CGSize.zero
    @State private var isLiking = false
    
    var body: some View {
        ZStack {
            ForEach(Array(users.prefix(3).enumerated().reversed()), id: \.element.id) { index, user in
                ProfileCardView(user: user)
                    .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height * 0.7)
                    .offset(x: index == 0 ? dragAmount.width : 0, y: index == 0 ? dragAmount.height * 0.3 : CGFloat(index * 5))
                    .rotationEffect(.degrees(index == 0 ? Double(dragAmount.width / 20) : 0))
                    .scaleEffect(index == 0 ? 1.0 : 1.0 - CGFloat(index) * 0.05)
                    .opacity(index < 2 ? 1.0 : 0.5)
                    .gesture(
                        index == 0 ?
                        DragGesture()
                            .onChanged { value in
                                dragAmount = value.translation
                            }
                            .onEnded { value in
                                handleSwipe(value.translation)
                            } : nil
                    )
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: dragAmount)
            }
            
            if !users.isEmpty {
                VStack {
                    Spacer()
                    
                    HStack(spacing: 40) {
                        Button(action: { handleReject() }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.red)
                                .frame(width: 70, height: 70)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        }
                        
                        Button(action: { handleLike() }) {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 30, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 70, height: 70)
                                .background(
                                    LinearGradient(
                                        colors: [.pink, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: .pink.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLiking)
                    }
                    .padding(.bottom, 40)
                }
            }
            
            if dragAmount.width > 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text("LIKE")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.green)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 5)
                            )
                            .rotationEffect(.degrees(-20))
                            .opacity(Double(dragAmount.width / 100))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 100)
            } else if dragAmount.width < 0 {
                VStack {
                    HStack {
                        Spacer()
                        Text("NOPE")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.red)
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.red, lineWidth: 5)
                            )
                            .rotationEffect(.degrees(20))
                            .opacity(Double(-dragAmount.width / 100))
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.top, 100)
            }
        }
    }
    
    private func handleSwipe(_ translation: CGSize) {
        if translation.width > 100 {
            handleLike()
        } else if translation.width < -100 {
            handleReject()
        } else {
            dragAmount = .zero
        }
    }
    
    private func handleLike() {
        guard !users.isEmpty, !isLiking else { return }
        
        let currentUser = users[0]
        isLiking = true
        
        withAnimation {
            dragAmount = CGSize(width: 500, height: 0)
        }
        
        Task {
            do {
                let response = try await APIClient.shared.likeUser(targetUserId: currentUser.id)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    users.removeFirst()
                    dragAmount = .zero
                    isLiking = false
                    
                    if response.isMatch, let match = response.match {
                        onMatch(match)
                    }
                }
            } catch {
                print("Like error: \(error)")
                dragAmount = .zero
                isLiking = false
            }
        }
    }
    
    private func handleReject() {
        guard !users.isEmpty else { return }
        
        withAnimation {
            dragAmount = CGSize(width: -500, height: 0)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            users.removeFirst()
            dragAmount = .zero
        }
    }
}
