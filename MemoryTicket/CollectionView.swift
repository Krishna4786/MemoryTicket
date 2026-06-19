import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var store: TicketStore
    @State private var search = ""
    @State private var appeared = false

    private var categories: [(TicketCategory, [MemoryTicket])] {
        let grouped = Dictionary(grouping: store.tickets, by: \.category)
        return TicketCategory.allCases.compactMap { cat in
            guard let tickets = grouped[cat], !tickets.isEmpty else { return nil }
            return (cat, tickets)
        }
    }

    private var searchResults: [MemoryTicket] {
        guard !search.isEmpty else { return [] }
        let q = search.lowercased()
        return store.tickets.filter {
            $0.title.lowercased().contains(q) ||
            ($0.location?.name.lowercased().contains(q) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    if search.isEmpty {
                        if store.tickets.isEmpty {
                            EmptyStateView(
                                icon: "square.grid.2x2",
                                title: "No tickets yet",
                                subtitle: "Your collection will appear here"
                            )
                            .padding(.top, 80)
                        } else {
                            // Hero banner
                            heroBanner
                                .padding(.horizontal, 16)
                                .stagger(0)

                            // Category folders grid
                            categoryGrid
                                .padding(.horizontal, 16)
                        }
                    } else {
                        searchList
                    }

                    Spacer(minLength: 100)
                }
                .padding(.top, 4)
            }
            .background(TH.bg.ignoresSafeArea())
            .navigationTitle("Collection")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $search, prompt: "Search memories...")
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        NavigationLink(destination: AllMemoriesView()) {
            ZStack(alignment: .bottomLeading) {
                // Photo mosaic background
                GeometryReader { geo in
                    HStack(spacing: 3) {
                        ForEach(0..<3, id: \.self) { col in
                            VStack(spacing: 3) {
                                ForEach(0..<2, id: \.self) { row in
                                    let idx = col * 2 + row
                                    if idx < store.tickets.count,
                                       let fn = store.tickets[idx].imageFileName,
                                       let img = store.loadImage(fileName: fn) {
                                        Image(uiImage: img)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(
                                                width: geo.size.width / 3 - 2,
                                                height: geo.size.height / 2 - 1.5
                                            )
                                            .clipped()
                                    } else {
                                        Rectangle()
                                            .fill(
                                                [Color(hex: "C7D2FE"), Color(hex: "FBCFE8"),
                                                 Color(hex: "FDE68A"), Color(hex: "A7F3D0"),
                                                 Color(hex: "BFDBFE"), Color(hex: "DDD6FE")
                                                ][idx % 6]
                                            )
                                            .frame(
                                                width: geo.size.width / 3 - 2,
                                                height: geo.size.height / 2 - 1.5
                                            )
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    // Dark gradient overlay
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.6)],
                        startPoint: .top, endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                )

                // Text overlay
                VStack(alignment: .leading, spacing: 4) {
                    Text("All Memories")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)

                    Text("\(store.tickets.count) tickets • \(categories.count) categories")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(18)
            }
        }
        .buttonStyle(CardButtonStyle())
    }

    // MARK: - Category Grid

    private var categoryGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)],
            spacing: 14
        ) {
            ForEach(Array(categories.enumerated()), id: \.element.0.id) { idx, item in
                let (cat, tickets) = item
                NavigationLink(destination: CategoryDetailView(category: cat)) {
                    FolderCard(category: cat, tickets: tickets)
                }
                .buttonStyle(FolderButtonStyle())
                .stagger(idx + 1)
            }
        }
    }

    // MARK: - Search

    private var searchList: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(searchResults.enumerated()), id: \.element.id) { idx, ticket in
                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                    RowCard(ticket: ticket)
                }
                .buttonStyle(CardButtonStyle())
                .stagger(idx)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Folder Card (Photo Stack + Category)

struct FolderCard: View {
    let category: TicketCategory
    let tickets: [MemoryTicket]
    @EnvironmentObject var store: TicketStore
    @State private var images: [UIImage] = []
    @State private var fanned = false

    var body: some View {
        VStack(spacing: 10) {
            // Photo stack
            ZStack {
                // Background folder shape
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(category.badgeColor.opacity(0.5))
                    .frame(height: 130)

                // Stacked photos
                if images.isEmpty {
                    // No photos — show icon
                    Image(systemName: category.icon)
                        .font(.system(size: 36, weight: .light))
                        .foregroundColor(category.color.opacity(0.4))
                } else {
                    ZStack {
                        ForEach(Array(images.prefix(3).enumerated().reversed()), id: \.offset) { i, img in
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: photoWidth(i), height: photoHeight(i))
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .shadow(color: .black.opacity(0.12), radius: 4, y: 2)
                                .rotationEffect(.degrees(fanned ? photoRotation(i) : 0))
                                .offset(
                                    x: fanned ? photoOffsetX(i) : 0,
                                    y: fanned ? photoOffsetY(i) : CGFloat(i) * -3
                                )
                        }
                    }
                }

                // Category badge (top-left)
                VStack {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 28, height: 28)
                            Image(systemName: category.icon)
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: category.color.opacity(0.3), radius: 4, y: 2)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(8)

                // Count badge (top-right)
                VStack {
                    HStack {
                        Spacer()
                        Text("\(tickets.count)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                            )
                    }
                    Spacer()
                }
                .padding(8)
            }
            .frame(height: 130)

            // Label
            VStack(spacing: 2) {
                Text(category.rawValue)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(TH.title)

                if let latest = tickets.first {
                    Text(latest.title)
                        .font(.system(size: 11))
                        .foregroundColor(TH.caption)
                        .lineLimit(1)
                }
            }
        }
        .onAppear {
            loadImages()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                fanned = true
            }
        }
    }

    // Fan-out positions for stacked photos
    private func photoWidth(_ i: Int) -> CGFloat {
        [100, 90, 80][min(i, 2)]
    }
    private func photoHeight(_ i: Int) -> CGFloat {
        [85, 78, 70][min(i, 2)]
    }
    private func photoRotation(_ i: Int) -> Double {
        [0, -8, 6][min(i, 2)]
    }
    private func photoOffsetX(_ i: Int) -> CGFloat {
        [0, -18, 16][min(i, 2)]
    }
    private func photoOffsetY(_ i: Int) -> CGFloat {
        [0, 5, -5][min(i, 2)]
    }

    private func loadImages() {
        images = tickets.prefix(3).compactMap { ticket in
            guard let fn = ticket.imageFileName else { return nil }
            return store.loadImage(fileName: fn)
        }
    }
}

// MARK: - Folder Button Style

struct FolderButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .rotation3DEffect(
                .degrees(configuration.isPressed ? 3 : 0),
                axis: (x: 1, y: 0, z: 0),
                perspective: 0.5
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - All Memories View

struct AllMemoriesView: View {
    @EnvironmentObject var store: TicketStore
    @State private var mode: ViewMode = .grid

    enum ViewMode { case grid, list }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                switch mode {
                case .grid: gridView.padding(.horizontal, 16)
                case .list: listView.padding(.horizontal, 20)
                }
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(TH.bg.ignoresSafeArea())
        .navigationTitle("All Memories")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    tBtn(.grid, "square.grid.2x2")
                    tBtn(.list, "list.bullet")
                }
                .padding(3)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(TH.bg))
            }
        }
    }

    private func tBtn(_ m: ViewMode, _ icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { mode = m }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(mode == m ? TH.accent : TH.caption)
                .frame(width: 28, height: 28)
                .background(RoundedRectangle(cornerRadius: 7).fill(mode == m ? TH.accentLight : .clear))
        }
    }

    private var gridView: some View {
        HStack(alignment: .top, spacing: 12) {
            LazyVStack(spacing: 12) {
                ForEach(Array(store.tickets.enumerated().filter { $0.offset % 2 == 0 }), id: \.element.id) { idx, t in
                    NavigationLink(destination: TicketDetailView(ticket: t)) {
                        GridCard(ticket: t)
                    }.buttonStyle(CardButtonStyle()).stagger(idx)
                }
            }
            LazyVStack(spacing: 12) {
                ForEach(Array(store.tickets.enumerated().filter { $0.offset % 2 == 1 }), id: \.element.id) { idx, t in
                    NavigationLink(destination: TicketDetailView(ticket: t)) {
                        GridCard(ticket: t)
                    }.buttonStyle(CardButtonStyle()).stagger(idx)
                }
            }
        }
    }

    private var listView: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(store.tickets.enumerated()), id: \.element.id) { idx, t in
                NavigationLink(destination: TicketDetailView(ticket: t)) {
                    RowCard(ticket: t)
                }.buttonStyle(CardButtonStyle()).stagger(idx)
            }
        }
    }
}

// MARK: - Category Detail View

struct CategoryDetailView: View {
    let category: TicketCategory
    @EnvironmentObject var store: TicketStore
    @State private var mode: ViewMode = .grid

    enum ViewMode { case grid, list }

    private var tickets: [MemoryTicket] {
        store.tickets.filter { $0.category == category }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Stats header
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(category.badgeColor)
                            .frame(width: 52, height: 52)
                        Image(systemName: category.icon)
                            .font(.system(size: 22))
                            .foregroundColor(category.color)
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text("\(tickets.count) ticket\(tickets.count == 1 ? "" : "s")")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(TH.title)
                        if let first = tickets.first {
                            Text("Latest: \(first.title)")
                                .font(.system(size: 13))
                                .foregroundColor(TH.caption)
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(TH.card).shadow(color: TH.shadow, radius: 6, y: 2))
                .padding(.horizontal, 16)
                .stagger(0)

                switch mode {
                case .grid: gridView.padding(.horizontal, 16)
                case .list: listView.padding(.horizontal, 20)
                }
                Spacer(minLength: 40)
            }
            .padding(.top, 8)
        }
        .background(TH.bg.ignoresSafeArea())
        .navigationTitle(category.rawValue)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 4) {
                    tBtn(.grid, "square.grid.2x2")
                    tBtn(.list, "list.bullet")
                }
                .padding(3)
                .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(TH.bg))
            }
        }
    }

    private func tBtn(_ m: ViewMode, _ icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { mode = m }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(mode == m ? TH.accent : TH.caption)
                .frame(width: 28, height: 28)
                .background(RoundedRectangle(cornerRadius: 7).fill(mode == m ? TH.accentLight : .clear))
        }
    }

    private var gridView: some View {
        HStack(alignment: .top, spacing: 12) {
            LazyVStack(spacing: 12) {
                ForEach(Array(tickets.enumerated().filter { $0.offset % 2 == 0 }), id: \.element.id) { idx, t in
                    NavigationLink(destination: TicketDetailView(ticket: t)) {
                        GridCard(ticket: t)
                    }.buttonStyle(CardButtonStyle()).stagger(idx + 1)
                }
            }
            LazyVStack(spacing: 12) {
                ForEach(Array(tickets.enumerated().filter { $0.offset % 2 == 1 }), id: \.element.id) { idx, t in
                    NavigationLink(destination: TicketDetailView(ticket: t)) {
                        GridCard(ticket: t)
                    }.buttonStyle(CardButtonStyle()).stagger(idx + 1)
                }
            }
        }
    }

    private var listView: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(tickets.enumerated()), id: \.element.id) { idx, t in
                NavigationLink(destination: TicketDetailView(ticket: t)) {
                    RowCard(ticket: t)
                }.buttonStyle(CardButtonStyle()).stagger(idx + 1)
            }
        }
    }
}
