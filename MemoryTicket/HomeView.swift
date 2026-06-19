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
                    header.padding(.horizontal, 20)
                    searchBar.padding(.horizontal, 20)

                    if store.streakCount > 0 {
                        streakBadge.stagger(1)
                    }

                    categoryPills.stagger(2)

                    if filtered.isEmpty {
                        emptyState.padding(.top, 50)
                    } else {
                        feedCards
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, 8)
            }
            .background(TH.bg.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Text("Memories")
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(TH.title)
            Spacer()
            Circle()
                .fill(Color(hex: "E5E7EB"))
                .frame(width: 38, height: 38)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 16))
                        .foregroundColor(TH.caption)
                )
        }
        .stagger(0)
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 15))
                .foregroundColor(TH.caption)

            TextField("Search", text: $searchText)
                .font(.system(size: 15))
                .foregroundColor(TH.title)

            if !searchText.isEmpty {
                Button { searchText = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 15))
                        .foregroundColor(TH.caption)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "E5E7EB").opacity(0.6))
        )
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
        .background(
            Capsule()
                .fill(Color(hex: "FEF3C7"))
        )
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
                .stagger(idx + 3)
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

// MARK: - Feed Card (large photo card)

struct FeedCard: View {
    let ticket: MemoryTicket
    @EnvironmentObject var store: TicketStore
    @State private var img: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Photo
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

            // Info
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
