import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var store: TicketStore
    @State private var selectedTab = 0
    @State private var showCreate = false

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showCreate: $showCreate)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            CollectionView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Albums")
                }
                .tag(1)

            Color.clear
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .tag(2)

            PlaceholderTab(icon: "map.fill", title: "Map", subtitle: "Coming in Phase 3")
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .tint(TH.accent)
        .onChange(of: selectedTab) { oldVal, newVal in
            if newVal == 2 {
                selectedTab = oldVal
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                showCreate = true
            }
        }
        .fullScreenCover(isPresented: $showCreate) {
            CreateTicketView().environmentObject(store)
        }
    }
}

// MARK: - Placeholder Tab

struct PlaceholderTab: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 14) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 44, weight: .light))
                .foregroundColor(TH.caption)
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(TH.title)
            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(TH.caption)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(TH.bg.ignoresSafeArea())
    }
}
