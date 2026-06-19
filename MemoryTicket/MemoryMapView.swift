//
//  MemoryMapView.swift
//  MemoryTicket
//
//  Created by krishna aggarwal on 19/06/26.
//


import SwiftUI
import MapKit

struct MemoryMapView: View {
    @EnvironmentObject var store: TicketStore
    @State private var position: MapCameraPosition = .automatic
    @State private var selectedTicket: MemoryTicket? = nil
    @State private var showCard = false

    private var mappableTickets: [MemoryTicket] {
        store.tickets.filter { $0.location?.latitude != nil && $0.location?.longitude != nil }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                // Map
                Map(position: $position, selection: .constant(nil)) {
                    ForEach(mappableTickets) { ticket in
                        if let lat = ticket.location?.latitude,
                           let lng = ticket.location?.longitude {
                            Annotation(
                                ticket.title,
                                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lng)
                            ) {
                                MapPin(ticket: ticket, isSelected: selectedTicket?.id == ticket.id) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        selectedTicket = ticket
                                        showCard = true
                                    }
                                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                }
                            }
                        }
                    }
                }
                .mapStyle(.standard(pointsOfInterest: .excludingAll))
                .ignoresSafeArea(edges: .top)

                // Bottom overlay
                VStack(spacing: 0) {
                    // Recenter + count bar
                    HStack {
                        // Memory count
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(TH.accent)
                            Text("\(mappableTickets.count) on map")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(TH.title)
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Capsule().fill(.regularMaterial))

                        Spacer()

                        // Recenter button
                        Button {
                            withAnimation(.spring(response: 0.5)) {
                                position = .automatic
                            }
                        } label: {
                            Image(systemName: "location.fill")
                                .font(.system(size: 15))
                                .foregroundColor(TH.accent)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(.regularMaterial))
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // Selected ticket card
                    if showCard, let ticket = selectedTicket {
                        NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                            TicketMapCard(ticket: ticket)
                        }
                        .buttonStyle(CardButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }

                // Empty state overlay
                if mappableTickets.isEmpty {
                    mapEmptyState
                }
            }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .onTapGesture {
                if showCard {
                    withAnimation(.spring(response: 0.3)) {
                        showCard = false
                        selectedTicket = nil
                    }
                }
            }
        }
    }

    // MARK: - Empty State

    private var mapEmptyState: some View {
        VStack(spacing: 16) {
            Spacer()

            VStack(spacing: 14) {
                Image(systemName: "map.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(TH.accent.opacity(0.6))

                Text("No locations yet")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(TH.title)

                Text("Add locations to your tickets\nand they'll appear on the map")
                    .font(.system(size: 14))
                    .foregroundColor(TH.caption)
                    .multilineTextAlignment(.center)

                // Tip
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "F59E0B"))

                    Text("Tip: Use \"city, country\" format when adding location")
                        .font(.system(size: 12))
                        .foregroundColor(TH.caption)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "FEF3C7").opacity(0.8))
                )
                .padding(.top, 4)
            }
            .padding(28)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
            )
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}

// MARK: - Custom Map Pin

struct MapPin: View {
    let ticket: MemoryTicket
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                ZStack {
                    // Pin bubble
                    Circle()
                        .fill(isSelected ? ticket.category.color : TH.card)
                        .frame(
                            width: isSelected ? 52 : 42,
                            height: isSelected ? 52 : 42
                        )
                        .shadow(
                            color: isSelected ? ticket.category.color.opacity(0.4) : .black.opacity(0.12),
                            radius: isSelected ? 8 : 4,
                            y: 2
                        )

                    if isSelected {
                        // Border ring
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                            .frame(width: 52, height: 52)
                    }

                    // Mood face
                    MoodFace(mood: ticket.moodType, size: isSelected ? 30 : 24)
                }

                // Pin tail
                MapTriangle()
                    .fill(isSelected ? ticket.category.color : TH.card)
                    .frame(width: 12, height: 8)
                    .rotationEffect(.degrees(180))
                    .offset(y: -3)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Triangle (reuse-safe)

private struct MapTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Ticket Map Card (bottom preview)

struct TicketMapCard: View {
    let ticket: MemoryTicket
    @EnvironmentObject var store: TicketStore
    @State private var img: UIImage? = nil

    var body: some View {
        HStack(spacing: 14) {
            // Photo thumbnail
            ZStack {
                if let img = img {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 72, height: 72)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(ticket.category.badgeColor)
                        .frame(width: 72, height: 72)
                        .overlay(
                            Image(systemName: ticket.category.icon)
                                .font(.system(size: 24))
                                .foregroundColor(ticket.category.color)
                        )
                }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(TH.title)
                    .lineLimit(1)

                if let loc = ticket.location {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin")
                            .font(.system(size: 10))
                        Text(loc.displayName)
                            .font(.system(size: 12))
                    }
                    .foregroundColor(TH.caption)
                }

                HStack(spacing: 8) {
                    Text(ticket.formattedDate)
                        .font(.system(size: 11))
                        .foregroundColor(TH.caption.opacity(0.7))

                    MoodFace(mood: ticket.moodType, size: 18)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(TH.caption)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(TH.card)
                .shadow(color: TH.shadowMd, radius: 12, y: 4)
        )
        .onAppear {
            if let fn = ticket.imageFileName { img = store.loadImage(fileName: fn) }
        }
    }
}
