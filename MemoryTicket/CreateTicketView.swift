import SwiftUI
import PhotosUI

struct CreateTicketView: View {
    @EnvironmentObject var store: TicketStore
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var notes = ""
    @State private var date = Date()
    @State private var locationName = ""
    @State private var category: TicketCategory = .custom
    @State private var selectedMood: MoodType = .happy
    @State private var selectedImage: UIImage? = nil
    @State private var photoItem: PhotosPickerItem? = nil

    @State private var step = 0
    @State private var showReveal = false
    @State private var createdTicket: MemoryTicket? = nil

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            if showReveal, let ticket = createdTicket {
                TicketRevealView(ticket: ticket, image: selectedImage) { dismiss() }
                    .transition(.opacity.combined(with: .scale(scale: 0.92)))
            } else {
                VStack(spacing: 0) {
                    nav
                    progress.padding(.horizontal, 20).padding(.top, 14)

                    TabView(selection: $step) {
                        stepPhoto.tag(0)
                        stepDetails.tag(1)
                        stepMood.tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.spring(response: 0.4, dampingFraction: 0.85), value: step)

                    buttons
                }
            }
        }
        .onChange(of: photoItem) { _, item in
            Task {
                if let data = try? await item?.loadTransferable(type: Data.self),
                   let img = UIImage(data: data) {
                    withAnimation(.spring(response: 0.35)) { selectedImage = img }
                }
            }
        }
    }

    // MARK: - Nav

    private var nav: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(TH.body)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(TH.bg))
            }
            Spacer()
            Text("New Memory")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(TH.title)
            Spacer()
            Color.clear.frame(width: 34, height: 34)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    // MARK: - Progress

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i <= step ? TH.accent : Color(hex: "E5E7EB"))
                    .frame(height: 4)
                    .animation(.spring(response: 0.35), value: step)
            }
        }
    }

    // MARK: - Step 1

    private var stepPhoto: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                sectionTitle("Photo & Title")

                PhotosPicker(selection: $photoItem, matching: .images) {
                    ZStack {
                        if let img = selectedImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        } else {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(TH.bg)
                                .frame(height: 200)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 1.5, dash: [7, 5]))
                                        .foregroundColor(Color(hex: "D1D5DB"))
                                )
                                .overlay(
                                    VStack(spacing: 10) {
                                        Image(systemName: "camera.fill")
                                            .font(.system(size: 28))
                                            .foregroundColor(TH.accent)
                                        Text("Add a photo")
                                            .font(.system(size: 14, weight: .medium))
                                            .foregroundColor(TH.caption)
                                    }
                                )
                        }
                    }
                }

                field("Title", placeholder: "e.g., Goa Trip", text: $title)
                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 2

    private var stepDetails: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 22) {
                sectionTitle("Details")

                VStack(alignment: .leading, spacing: 6) {
                    Text("Date").font(.system(size: 13, weight: .semibold)).foregroundColor(TH.caption)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .tint(TH.accent)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(TH.bg))
                }

                field("Location", placeholder: "e.g., Goa Beach", text: $locationName)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes").font(.system(size: 13, weight: .semibold)).foregroundColor(TH.caption)
                    TextEditor(text: $notes)
                        .font(.system(size: 15))
                        .foregroundColor(TH.title)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 90)
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(TH.bg))
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 3: Category + Mood Characters

    private var stepMood: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                sectionTitle("Category & Mood")

                // Category grid
                VStack(alignment: .leading, spacing: 10) {
                    Text("Category").font(.system(size: 13, weight: .semibold)).foregroundColor(TH.caption)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                        ForEach(TicketCategory.allCases) { cat in
                            Button {
                                withAnimation(.spring(response: 0.3)) { category = cat }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                VStack(spacing: 6) {
                                    Image(systemName: cat.icon)
                                        .font(.system(size: 18))
                                    Text(cat.rawValue)
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundColor(category == cat ? .white : cat.color)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .fill(category == cat ? cat.color : cat.badgeColor)
                                )
                                .scaleEffect(category == cat ? 1.04 : 1)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Mood character preview
                VStack(spacing: 16) {
                    Text("How did it feel?")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(TH.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Large mood preview
                    VStack(spacing: 8) {
                        MoodFace(mood: selectedMood, size: 100)
                            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: selectedMood)

                        Text(selectedMood.label)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(TH.title)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(selectedMood.bgColor)
                    )

                    // Mood character grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4), spacing: 10) {
                        ForEach(MoodType.allCases) { mood in
                            MoodPickerCell(mood: mood, isSelected: selectedMood == mood) {
                                withAnimation(.spring(response: 0.35, dampingFraction: 0.65)) {
                                    selectedMood = mood
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Buttons

    private var buttons: some View {
        HStack(spacing: 10) {
            if step > 0 {
                Button {
                    withAnimation(.spring(response: 0.35)) { step -= 1 }
                } label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(TH.body)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(TH.bg))
                }
            }

            Button {
                if step < 2 {
                    withAnimation(.spring(response: 0.35)) { step += 1 }
                } else {
                    create()
                }
            } label: {
                HStack(spacing: 6) {
                    Text(step == 2 ? "Create Ticket" : "Next")
                    if step == 2 { Image(systemName: "sparkles") }
                }
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Capsule().fill(canProceed ? TH.accent : TH.accent.opacity(0.35)))
            }
            .disabled(!canProceed)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    private var canProceed: Bool {
        step == 0 ? !title.trimmingCharacters(in: .whitespaces).isEmpty : true
    }

    // MARK: - Helpers

    private func sectionTitle(_ t: String) -> some View {
        Text(t)
            .font(.system(size: 22, weight: .bold))
            .foregroundColor(TH.title)
            .padding(.top, 16)
    }

    private func field(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label).font(.system(size: 13, weight: .semibold)).foregroundColor(TH.caption)
            TextField(placeholder, text: text)
                .font(.system(size: 16))
                .foregroundColor(TH.title)
                .padding(14)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(TH.bg))
        }
    }

    // MARK: - Create

    private func create() {
        var fn: String? = nil
        if let img = selectedImage {
            fn = "\(UUID().uuidString).jpg"
            store.saveImage(img, fileName: fn!)
        }
        let loc: LocationInfo? = locationName.isEmpty ? nil : LocationInfo(name: locationName)
        let ticket = MemoryTicket(
            title: title, imageFileName: fn, date: date,
            location: loc, notes: notes, category: category, mood: selectedMood.rawValue
        )
        store.addTicket(ticket)
        createdTicket = ticket
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { showReveal = true }
    }
}

// MARK: - Reveal

struct TicketRevealView: View {
    let ticket: MemoryTicket
    let image: UIImage?
    let onDone: () -> Void

    @State private var cardScale: CGFloat = 0.5
    @State private var cardOpacity: Double = 0
    @State private var faceScale: CGFloat = 2.5
    @State private var faceOpacity: Double = 0
    @State private var btnOpacity: Double = 0
    @State private var confetti: [CParticle] = (0..<30).map { _ in CParticle() }
    @State private var burst = false

    var body: some View {
        ZStack {
            TH.bg.ignoresSafeArea()

            ForEach(confetti) { p in
                Circle().fill(p.color).frame(width: p.size, height: p.size)
                    .offset(x: burst ? p.dx : 0, y: burst ? p.dy : 0)
                    .opacity(burst ? 0 : 1)
            }

            VStack(spacing: 28) {
                Spacer()

                Text("Memory Created!")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(TH.title)
                    .opacity(cardOpacity)

                TicketPreviewCard(ticket: ticket, image: image)
                    .frame(maxWidth: 300)
                    .scaleEffect(cardScale)
                    .opacity(cardOpacity)

                // Mood face instead of emoji
                MoodFace(mood: ticket.moodType, size: 72)
                    .scaleEffect(faceScale)
                    .opacity(faceOpacity)

                Spacer()

                Button(action: onDone) {
                    Text("Done")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(Capsule().fill(TH.accent))
                }
                .padding(.horizontal, 40)
                .opacity(btnOpacity)
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) {
                cardScale = 1; cardOpacity = 1
            }
            withAnimation(.spring(response: 0.25, dampingFraction: 0.5).delay(0.6)) {
                faceScale = 1; faceOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                withAnimation(.easeOut(duration: 1.2)) { burst = true }
            }
            withAnimation(.easeOut(duration: 0.4).delay(1.1)) { btnOpacity = 1 }
        }
    }
}

struct CParticle: Identifiable {
    let id = UUID()
    let color: Color = [
        Color(hex: "3478F6"), Color(hex: "F59E0B"), Color(hex: "10B981"),
        Color(hex: "EF4444"), Color(hex: "8B5CF6"), Color(hex: "EC4899")
    ].randomElement()!
    let dx: CGFloat = .random(in: -160...160)
    let dy: CGFloat = .random(in: -200...80)
    let size: CGFloat = .random(in: 5...9)
}
