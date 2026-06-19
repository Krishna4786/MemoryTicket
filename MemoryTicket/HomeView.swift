import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: TicketStore
    @Binding var showCreate: Bool
    @State private var searchText = ""
    @State private var selectedCategory: TicketCategory? = nil

    private var filtered: [MemoryTicket] {
        var list = store.tickets
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            list = list.filter {
                $0.title.lowercased().contains(q) ||
                ($0.location?.name.lowercased().contains(q) ?? false)
            }
        }
        if let c = selectedCategory { list = list.filter { $0.category == c } }
        return list
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if store.streakCount > 0 {
                        streakBadge.stagger(0)
                    }

                    categoryPills.stagger(1)

                    if filtered.isEmpty {
                        emptyState.padding(.top, 50)
                    } else {
                        feedCards
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, 4)
            }
            .background(TH.bg.ignoresSafeArea())
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search memories")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    avatarView
                }
            }
        }
    }

    // MARK: - Avatar (matches Profile)

    private var avatarView: some View {
        Group {
            if let img = loadAvatar() {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "C7D2FE"), Color(hex: "A5B4FC")],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    )
            }
        }
    }

    private func loadAvatar() -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar.jpg")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Streak Badge

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(Color(hex: "F59E0B"))
            Text("\(store.streakCount) Day Streak")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(TH.title)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color(hex: "FEF3C7")))
    }

    // MARK: - Category Pills

    private var categoryPills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pillButton("All", selected: selectedCategory == nil) {
                    withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                }
                ForEach(TicketCategory.allCases) { cat in
                    pillButton(cat.rawValue, selected: selectedCategory == cat) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedCategory = selectedCategory == cat ? nil : cat
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func pillButton(_ text: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 14, weight: selected ? .semibold : .medium))
                .foregroundColor(selected ? .white : TH.body)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(selected ? TH.accent : TH.card)
                        .shadow(color: selected ? .clear : TH.shadow, radius: 4, y: 1)
                )
        }
    }

    // MARK: - Feed Cards

    private var feedCards: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, ticket in
                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                    FeedCard(ticket: ticket)
                }
                .buttonStyle(CardButtonStyle())
                .stagger(idx + 2)
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 20) {
            EmptyStateView(
                icon: "ticket.fill",
                title: "No memories yet",
                subtitle: "Tap + to capture your first moment"
            )
            Button {
                showCreate = true
            } label: {
                Text("Create First Ticket")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(TH.accent))
            }
        }
    }
}

// MARK: - Feed Card

struct FeedCard: View {
    let ticket: MemoryTicket
    @EnvironmentObject var store: TicketStore
    @State private var img: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                if let img = img {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 220)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [ticket.category.color.opacity(0.3), ticket.category.color.opacity(0.1)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 220)
                        .overlay(
                            Image(systemName: ticket.category.icon)
                                .font(.system(size: 40, weight: .light))
                                .foregroundColor(ticket.category.color.opacity(0.4))
                        )
                }

                DateBadge(text: ticket.shortDate)
                    .padding(12)
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16, bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0, topTrailingRadius: 16
                )
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(ticket.title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(TH.title)
                    .lineLimit(1)

                if let loc = ticket.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 11))
                        Text(loc.displayName)
                            .font(.system(size: 13))
                    }
                    .foregroundColor(TH.caption)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
        .background(TH.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: TH.shadow, radius: 8, y: 3)
        .onAppear {
            if let fn = ticket.imageFileName { img = store.loadImage(fileName: fn) }
        }
    }
}

// MARK: - Card Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.spring(response: 0.25), value: configuration.isPressed)
    }
}
