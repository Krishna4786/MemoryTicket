import SwiftUI

struct CollectionView: View {
    @EnvironmentObject var store: TicketStore
    @State private var search = ""
    @State private var cat: TicketCategory? = nil
    @State private var mode: Mode = .grid

    enum Mode { case grid, list }

    private var filtered: [MemoryTicket] {
        var r = store.tickets
        if !search.isEmpty {
            let q = search.lowercased()
            r = r.filter {
                $0.title.lowercased().contains(q) ||
                ($0.location?.name.lowercased().contains(q) ?? false)
            }
        }
        if let c = cat { r = r.filter { $0.category == c } }
        return r
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    header.padding(.horizontal, 20)
                    searchBar.padding(.horizontal, 20)
                    pills

                    if filtered.isEmpty {
                        EmptyStateView(
                            icon: search.isEmpty ? "square.grid.2x2" : "magnifyingglass",
                            title: search.isEmpty ? "No tickets yet" : "No results",
                            subtitle: search.isEmpty ? "Your collection will appear here" : "Try different keywords"
                        )
                        .padding(.top, 50)
                    } else {
                        switch mode {
                        case .grid: masonryGrid.padding(.horizontal, 16)
                        case .list: listView.padding(.horizontal, 20)
                        }
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
            VStack(alignment: .leading, spacing: 2) {
                Text("Collection")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(TH.title)
                if !store.tickets.isEmpty {
                    Text("\(store.tickets.count) memories")
                        .font(.system(size: 13))
                        .foregroundColor(TH.caption)
                }
            }
            Spacer()
            HStack(spacing: 4) {
                modeBtn(.grid, icon: "square.grid.2x2")
                modeBtn(.list, icon: "list.bullet")
            }
            .padding(3)
            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(TH.bg))
        }
    }

    private func modeBtn(_ m: Mode, icon: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { mode = m }
        } label: {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(mode == m ? TH.accent : TH.caption)
                .frame(width: 30, height: 30)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(mode == m ? TH.accentLight : Color.clear)
                )
        }
    }

    // MARK: - Search

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 14))
                .foregroundColor(TH.caption)
            TextField("Search memories...", text: $search)
                .font(.system(size: 14))
                .foregroundColor(TH.title)
            if !search.isEmpty {
                Button { search = "" } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(TH.caption)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(RoundedRectangle(cornerRadius: 11, style: .continuous).fill(Color(hex: "E5E7EB").opacity(0.5)))
    }

    // MARK: - Pills

    private var pills: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                pill("All", sel: cat == nil) {
                    withAnimation(.spring(response: 0.3)) { cat = nil }
                }
                ForEach(TicketCategory.allCases) { c in
                    pill(c.rawValue, sel: cat == c) {
                        withAnimation(.spring(response: 0.3)) { cat = cat == c ? nil : c }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func pill(_ t: String, sel: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(t)
                .font(.system(size: 13, weight: sel ? .semibold : .medium))
                .foregroundColor(sel ? .white : TH.body)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    Capsule().fill(sel ? TH.accent : TH.card)
                        .shadow(color: sel ? .clear : TH.shadow, radius: 3, y: 1)
                )
        }
    }

    // MARK: - Masonry Grid

    private var masonryGrid: some View {
        HStack(alignment: .top, spacing: 12) {
            // Left column
            LazyVStack(spacing: 12) {
                ForEach(Array(leftColumn.enumerated()), id: \.element.id) { idx, ticket in
                    NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                        GridCard(ticket: ticket)
                    }
                    .buttonStyle(CardButtonStyle())
                    .stagger(idx)
                }
            }

            // Right column
            LazyVStack(spacing: 12) {
                ForEach(Array(rightColumn.enumerated()), id: \.element.id) { idx, ticket in
                    NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                        GridCard(ticket: ticket)
                    }
                    .buttonStyle(CardButtonStyle())
                    .stagger(idx)
                }
            }
        }
    }

    private var leftColumn: [MemoryTicket] {
        filtered.enumerated().compactMap { $0.offset % 2 == 0 ? $0.element : nil }
    }
    private var rightColumn: [MemoryTicket] {
        filtered.enumerated().compactMap { $0.offset % 2 == 1 ? $0.element : nil }
    }

    // MARK: - List

    private var listView: some View {
        LazyVStack(spacing: 10) {
            ForEach(Array(filtered.enumerated()), id: \.element.id) { idx, ticket in
                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                    RowCard(ticket: ticket)
                }
                .buttonStyle(CardButtonStyle())
                .stagger(idx)
            }
        }
    }
}
