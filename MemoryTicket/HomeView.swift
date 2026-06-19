import SwiftUI
import AudioToolbox

struct HomeView: View {
    @EnvironmentObject var store: TicketStore
    @Binding var showCreate: Bool
    @State private var searchText = ""
    @State private var selectedCategory: TicketCategory? = nil
    @State private var showFilter = false

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
            ZStack {
                // Main content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        if store.streakCount > 0 {
                            streakBadge.stagger(0)
                        }

                        if let cat = selectedCategory {
                            activeFilter(cat).stagger(0)
                        }

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

                // Full-screen filter overlay
                if showFilter {
                    filterOverlay
                }
            }
            .navigationTitle("Memories")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Search memories")
            .toolbar(showFilter ? .hidden : .visible, for: .navigationBar)
            .toolbar {
                if !showFilter {
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 10) {
                            Button {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showFilter = true
                                }
                            } label: {
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "line.3.horizontal.decrease.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(selectedCategory != nil ? TH.accent : TH.body)
                                    if selectedCategory != nil {
                                        Circle().fill(TH.accent)
                                            .frame(width: 8, height: 8)
                                            .offset(x: 2, y: -2)
                                    }
                                }
                            }
                            avatarView
                        }
                    }
                }
            }
        }
    }

    // MARK: - Filter Overlay (full screen)

    private var filterOverlay: some View {
        ZStack {
            // Dim background — solid dark
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        showFilter = false
                    }
                }
                .transition(.opacity)

            // Panel from right
            HStack(spacing: 0) {
                Spacer()

                CurvedFilterPanel(
                    selectedCategory: $selectedCategory,
                    onClose: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                            showFilter = false
                        }
                    }
                )
                .transition(.move(edge: .trailing))
            }
        }
    }

    // MARK: - Active Filter Chip

    private func activeFilter(_ cat: TicketCategory) -> some View {
        HStack(spacing: 8) {
            Image(systemName: cat.icon)
                .font(.system(size: 12))
                .foregroundColor(cat.color)
            Text(cat.rawValue)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(TH.title)
            Button {
                withAnimation(.spring(response: 0.3)) { selectedCategory = nil }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(TH.caption)
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(Color(hex: "E5E7EB")))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(cat.badgeColor)
                .overlay(Capsule().stroke(cat.color.opacity(0.3), lineWidth: 1))
        )
    }

    // MARK: - Avatar

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
                    .fill(LinearGradient(colors: [Color(hex: "C7D2FE"), Color(hex: "A5B4FC")], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 32, height: 32)
                    .overlay(Image(systemName: "person.fill").font(.system(size: 14)).foregroundColor(.white))
            }
        }
    }

    private func loadAvatar() -> UIImage? {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("avatar.jpg")
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    // MARK: - Streak

    private var streakBadge: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill").font(.system(size: 13, weight: .semibold)).foregroundColor(Color(hex: "F59E0B"))
            Text("\(store.streakCount) Day Streak").font(.system(size: 13, weight: .bold)).foregroundColor(TH.title)
        }
        .padding(.horizontal, 14).padding(.vertical, 8)
        .background(Capsule().fill(Color(hex: "FEF3C7")))
    }

    // MARK: - Feed

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

    private var emptyState: some View {
        VStack(spacing: 20) {
            EmptyStateView(icon: "ticket.fill", title: "No memories yet", subtitle: "Tap + to capture your first moment")
            Button { showCreate = true } label: {
                Text("Create First Ticket").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    .padding(.horizontal, 24).padding(.vertical, 12).background(Capsule().fill(TH.accent))
            }
        }
    }
}

// MARK: - Curved Filter Panel (full height, drag-to-select)

struct CurvedFilterPanel: View {
    @Binding var selectedCategory: TicketCategory?
    var onClose: () -> Void

    @State private var appeared = false
    @State private var dragHighlight: Int? = nil

    private var options: [(TicketCategory?, String, String)] {
        [(nil, "All", "square.grid.2x2")] +
        TicketCategory.allCases.map { ($0, $0.rawValue, $0.icon) }
    }

    private let itemHeight: CGFloat = 68

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Filter")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(TH.title)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(TH.caption)
                        .frame(width: 32, height: 32)
                        .background(Circle().fill(Color(hex: "F3F4F6")))
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)

            // Scrollable curved items with drag-to-select
            GeometryReader { geo in
                let totalH = geo.size.height
                let w = geo.size.width
                let count = options.count
                let spacing = min(totalH / CGFloat(count), itemHeight)

                ZStack {
                    // Items
                    ForEach(Array(options.enumerated()), id: \.offset) { idx, opt in
                        let (cat, label, icon) = opt
                        let y = CGFloat(idx) * spacing + spacing / 2
                        let ix = iconX(index: idx, count: count, width: w)
                        let isSelected = selectedCategory == cat
                        let isDragHL = dragHighlight == idx

                        HStack(spacing: 12) {
                            // Label
                            Text(label)
                                .font(.system(size: 15, weight: isSelected || isDragHL ? .bold : .medium))
                                .foregroundColor(isSelected || isDragHL ? TH.title : TH.caption)
                                .padding(.horizontal, isSelected ? 14 : 0)
                                .padding(.vertical, isSelected ? 6 : 0)
                                .background(
                                    Group {
                                        if isSelected {
                                            Capsule().fill(TH.card)
                                                .shadow(color: TH.shadow, radius: 4, y: 1)
                                        }
                                    }
                                )

                            // Icon
                            ZStack {
                                Circle()
                                    .fill(isSelected || isDragHL
                                        ? (cat?.color ?? TH.accent)
                                        : Color(hex: "F3F4F6")
                                    )
                                    .frame(
                                        width: isSelected ? 50 : (isDragHL ? 46 : 40),
                                        height: isSelected ? 50 : (isDragHL ? 46 : 40)
                                    )

                                if isSelected {
                                    Circle()
                                        .stroke((cat?.color ?? TH.accent).opacity(0.3), lineWidth: 2)
                                        .frame(width: 58, height: 58)
                                }

                                Image(systemName: icon)
                                    .font(.system(size: isSelected ? 20 : 16))
                                    .foregroundColor(isSelected || isDragHL ? .white : (cat?.color ?? TH.caption))
                            }

                            // Indicator bar
                            if isSelected {
                                Capsule()
                                    .fill(Color(hex: "1F2937"))
                                    .frame(width: 32, height: 6)
                            }
                        }
                        .position(x: ix, y: y)
                        .opacity(appeared ? 1 : 0)
                        .offset(x: appeared ? 0 : 50)
                        .animation(
                            .spring(response: 0.45, dampingFraction: 0.75).delay(Double(idx) * 0.04),
                            value: appeared
                        )
                        .animation(.spring(response: 0.3), value: isSelected)
                        .animation(.spring(response: 0.25), value: isDragHL)
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let spacing = min(totalH / CGFloat(count), itemHeight)
                            let idx = Int((value.location.y) / spacing)
                            let clamped = max(0, min(count - 1, idx))

                            if dragHighlight != clamped {
                                dragHighlight = clamped
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                AudioServicesPlaySystemSound(1104)
                            }
                        }
                        .onEnded { _ in
                            if let hl = dragHighlight {
                                let cat = options[hl].0
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                    selectedCategory = cat
                                }
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                AudioServicesPlaySystemSound(1057)
                            }
                            dragHighlight = nil

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onClose()
                            }
                        }
                )
            }
        }
        .frame(width: UIScreen.main.bounds.width * 0.72)
        .frame(maxHeight: .infinity)
        .padding(.top, 50)
        .padding(.bottom, 90)
        .background(
            Color.white
                .clipShape(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                )
                .shadow(color: .black.opacity(0.15), radius: 24, x: -6, y: 0)
                .padding(.top, 50)
                .padding(.bottom, 90)
        )
        .onAppear { appeared = true }
    }

    // S-curve offset
    private func iconX(index: Int, count: Int, width: CGFloat) -> CGFloat {
        let progress = CGFloat(index) / CGFloat(max(count - 1, 1))
        let center = width * 0.5
        let amp = width * 0.12
        return center + sin(progress * .pi * 1.3 - .pi * 0.15) * amp
    }
}

// MARK: - Curve Path

struct CurvePath: Shape {
    let points: [CGPoint]
    func path(in rect: CGRect) -> Path {
        var p = Path()
        guard points.count > 1 else { return p }
        p.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let midY = (prev.y + curr.y) / 2
            p.addCurve(to: curr, control1: CGPoint(x: prev.x, y: midY), control2: CGPoint(x: curr.x, y: midY))
        }
        return p
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
                        .resizable().aspectRatio(contentMode: .fill)
                        .frame(height: 220).clipped()
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [ticket.category.color.opacity(0.3), ticket.category.color.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(height: 220)
                        .overlay(Image(systemName: ticket.category.icon).font(.system(size: 40, weight: .light)).foregroundColor(ticket.category.color.opacity(0.4)))
                }
                DateBadge(text: ticket.shortDate).padding(12)
            }
            .clipShape(UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16))

            VStack(alignment: .leading, spacing: 6) {
                Text(ticket.title).font(.system(size: 18, weight: .bold)).foregroundColor(TH.title).lineLimit(1)
                if let loc = ticket.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin").font(.system(size: 11))
                        Text(loc.displayName).font(.system(size: 13))
                    }.foregroundColor(TH.caption)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
        }
        .background(TH.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: TH.shadow, radius: 8, y: 3)
        .onAppear { if let fn = ticket.imageFileName { img = store.loadImage(fileName: fn) } }
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.spring(response: 0.25), value: configuration.isPressed)
    }
}
