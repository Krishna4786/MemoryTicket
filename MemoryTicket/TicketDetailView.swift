import SwiftUI

struct TicketDetailView: View {
    let ticket: MemoryTicket
    @EnvironmentObject var store: TicketStore
    @Environment(\.dismiss) var dismiss

    @State private var appeared = false
    @State private var showShare = false
    @State private var showDelete = false
    @State private var shareImage: UIImage? = nil

    var body: some View {
        ZStack {
            TH.bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Ticket card
                    TicketPreviewCard(ticket: ticket)
                        .padding(.horizontal, 30)
                        .padding(.top, 12)
                        .scaleEffect(appeared ? 1 : 0.92)
                        .opacity(appeared ? 1 : 0)

                    // Action buttons (circular, like Image 3)
                    actionRow
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 16)

                    // Detail cards
                    detailSection
                        .padding(.horizontal, 20)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 24)

                    if !ticket.notes.isEmpty {
                        notesSection
                            .padding(.horizontal, 20)
                            .opacity(appeared ? 1 : 0)
                    }

                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { dismiss() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TH.body)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(TH.card).shadow(color: TH.shadow, radius: 4, y: 1))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Preview")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(TH.title)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(role: .destructive) { showDelete = true } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(TH.body)
                        .frame(width: 34, height: 34)
                        .background(Circle().fill(TH.card).shadow(color: TH.shadow, radius: 4, y: 1))
                }
            }
        }
        .alert("Delete Memory?", isPresented: $showDelete) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) { store.deleteTicket(ticket); dismiss() }
        } message: {
            Text("This ticket will be permanently removed.")
        }
        .sheet(isPresented: $showShare) {
            if let img = shareImage { ShareSheet(items: [img]) }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Action Row

    private var actionRow: some View {
        HStack(spacing: 28) {
            circleAction(icon: "pencil", label: "Edit") {
                // placeholder for edit
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            circleAction(icon: "square.and.arrow.up", label: "Share") {
                doShare()
            }
            circleAction(icon: "arrow.down.to.line", label: "Save") {
                saveToPhotos()
            }
        }
    }

    private func circleAction(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "374151"))
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                }

                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(TH.caption)
            }
        }
        .buttonStyle(CardButtonStyle())
    }

    // MARK: - Detail Section

    private var detailSection: some View {
        VStack(spacing: 0) {
            detailRow(icon: "calendar", label: "Date", value: ticket.formattedDate)
            Divider().padding(.leading, 44)
            if let loc = ticket.location {
                detailRow(icon: "mappin.circle", label: "Location", value: loc.displayName)
                Divider().padding(.leading, 44)
            }
            detailRow(icon: "tag", label: "Category", value: ticket.category.rawValue)
            Divider().padding(.leading, 44)
            HStack(spacing: 12) {
                    Image(systemName: "face.smiling")
                        .font(.system(size: 15))
                        .foregroundColor(TH.accent)
                        .frame(width: 22)
                    Text("Mood")
                        .font(.system(size: 14))
                        .foregroundColor(TH.caption)
                    Spacer()
                    HStack(spacing: 6) {
                        MoodFace(mood: ticket.moodType, size: 24)
                        Text(ticket.moodType.label)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(TH.title)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
        }
        .card()
    }

    private func detailRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 15))
                .foregroundColor(TH.accent)
                .frame(width: 22)

            Text(label)
                .font(.system(size: 14))
                .foregroundColor(TH.caption)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(TH.title)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
    }

    // MARK: - Notes

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "note.text")
                    .font(.system(size: 14))
                    .foregroundColor(TH.accent)
                Text("Notes")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(TH.title)
            }

            Text(ticket.notes)
                .font(.system(size: 14))
                .foregroundColor(TH.body)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card(padding: 16)
    }

    // MARK: - Actions

    private func doShare() {
        let renderer = ImageRenderer(content:
            TicketPreviewCard(ticket: ticket)
                .environmentObject(store)
                .frame(width: 320)
                .padding(16)
                .background(TH.bg)
        )
        renderer.scale = 3
        if let img = renderer.uiImage {
            shareImage = img
            showShare = true
        }
    }

    private func saveToPhotos() {
        let renderer = ImageRenderer(content:
            TicketPreviewCard(ticket: ticket)
                .environmentObject(store)
                .frame(width: 320)
                .padding(16)
                .background(TH.bg)
        )
        renderer.scale = 3
        if let img = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}
