import SwiftUI

// MARK: - Ticket Preview Card (detail/reveal)

struct TicketPreviewCard: View {
    let ticket: MemoryTicket
    var image: UIImage? = nil

    @EnvironmentObject var store: TicketStore
    @State private var loadedImage: UIImage? = nil
    private var display: UIImage? { image ?? loadedImage }

    var body: some View {
        VStack(spacing: 0) {
            // Photo
            ZStack(alignment: .bottomLeading) {
                if let img = display {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [ticket.category.color.opacity(0.2), ticket.category.color.opacity(0.05)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 240)
                        .overlay(
                            Image(systemName: ticket.category.icon)
                                .font(.system(size: 44, weight: .light))
                                .foregroundColor(ticket.category.color.opacity(0.3))
                        )
                }

                // Mood face badge (bottom left)
                MoodBadge(mood: ticket.moodType, size: 34)
                    .padding(10)
            }

            DottedLine()
                .padding(.horizontal, 16)
                .padding(.vertical, 10)

            // Details
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    Text(ticket.title)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(TH.title)
                        .lineLimit(2)
                    Spacer()
                    Text("VERIFIED MEMORY")
                        .font(.system(size: 8, weight: .bold))
                        .tracking(0.5)
                        .foregroundColor(Color(hex: "E8784E"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .stroke(Color(hex: "E8784E"), lineWidth: 1)
                        )
                }

                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar").font(.system(size: 13)).foregroundColor(TH.caption)
                        Text(ticket.formattedDate).font(.system(size: 13)).foregroundColor(TH.caption)
                    }
                    Spacer()
                    Image(systemName: "qrcode")
                        .font(.system(size: 32))
                        .foregroundColor(TH.title.opacity(0.2))
                }

                if let loc = ticket.location {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin").font(.system(size: 13)).foregroundColor(TH.caption)
                        Text(loc.displayName).font(.system(size: 13)).foregroundColor(TH.caption)
                    }
                    .padding(.top, -4)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .background(TH.card)
        .clipShape(TicketShape())
        .shadow(color: TH.shadowMd, radius: 16, y: 6)
        .onAppear {
            if image == nil, let fn = ticket.imageFileName { loadedImage = store.loadImage(fileName: fn) }
        }
    }
}

// MARK: - Grid Card (collection masonry)

struct GridCard: View {
    let ticket: MemoryTicket
    @EnvironmentObject var store: TicketStore
    @State private var img: UIImage? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                if let img = img {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(minHeight: 140, maxHeight: 200)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [ticket.category.color.opacity(0.25), ticket.category.color.opacity(0.08)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 160)
                        .overlay(
                            Image(systemName: ticket.category.icon)
                                .font(.system(size: 30, weight: .light))
                                .foregroundColor(ticket.category.color.opacity(0.35))
                        )
                }

                DateBadge(text: ticket.shortDate, color: ticket.category.color)
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(ticket.title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(TH.title)
                        .lineLimit(1)
                    Spacer()
                    MoodFace(mood: ticket.moodType, size: 22)
                }

                if let loc = ticket.location {
                    HStack(spacing: 3) {
                        Image(systemName: ticket.category.icon).font(.system(size: 10))
                        Text(loc.displayName).font(.system(size: 12))
                    }
                    .foregroundColor(TH.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .background(TH.card)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: TH.shadow, radius: 6, y: 2)
        .onAppear {
            if let fn = ticket.imageFileName { img = store.loadImage(fileName: fn) }
        }
    }
}

// MARK: - Row Card (list view)

struct RowCard: View {
    let ticket: MemoryTicket
    @EnvironmentObject var store: TicketStore
    @State private var img: UIImage? = nil

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                if let img = img {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 62, height: 62)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(ticket.category.badgeColor)
                        .frame(width: 62, height: 62)
                        .overlay(
                            Image(systemName: ticket.category.icon)
                                .font(.system(size: 20))
                                .foregroundColor(ticket.category.color)
                        )
                }
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(ticket.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(TH.title)
                    .lineLimit(1)
                if let loc = ticket.location {
                    HStack(spacing: 3) {
                        Image(systemName: "mappin").font(.system(size: 10))
                        Text(loc.displayName).lineLimit(1)
                    }
                    .font(.system(size: 12)).foregroundColor(TH.caption)
                }
                Text(ticket.formattedDate)
                    .font(.system(size: 11)).foregroundColor(TH.caption.opacity(0.7))
            }

            Spacer()

            MoodFace(mood: ticket.moodType, size: 32)
        }
        .padding(12)
        .background(TH.card)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: TH.shadow, radius: 4, y: 1)
        .onAppear {
            if let fn = ticket.imageFileName { img = store.loadImage(fileName: fn) }
        }
    }
}
