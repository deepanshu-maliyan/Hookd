import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DatingFeedView()
                .tabItem {
                    Label("Dating", systemImage: "heart.fill")
                }
                .tag(0)
            
            MatchesListView()
                .tabItem {
                    Label("Matches", systemImage: "message.fill")
                }
                .tag(1)
            
            ConfessionsListView()
                .tabItem {
                    Label("Confessions", systemImage: "text.bubble.fill")
                }
                .tag(2)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(3)
        }
        .tint(.pink)
    }
}
