//
//  ProfileView.swift
//  MemoryTicket
//
//  Created by krishna aggarwal on 19/06/26.
//


import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var store: TicketStore
    @State private var userName = UserDefaults.standard.string(forKey: "user_name") ?? ""
    @State private var showNameEdit = false
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var avatarImage: UIImage? = nil
    @State private var headerVisible = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Animated header with floating moods
                    profileHeader
                        .padding(.top, 8)

                    // Stats cards
                    statsGrid
                        .padding(.horizontal, 20)

                    // Invite card
                    inviteCard
                        .padding(.horizontal, 20)
                        .stagger(4)

                    // Settings sections
                    settingsSections
                        .padding(.horizontal, 20)
                        .stagger(5)

                    // App info
                    appInfo
                        .stagger(6)

                    Spacer(minLength: 100)
                }
            }
            .background(TH.bg.ignoresSafeArea())
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .onChange(of: photoItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self),
                       let img = UIImage(data: data) {
                        avatarImage = img
                        saveAvatar(img)
                    }
                }
            }
            .onAppear {
                loadAvatar()
                withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.2)) {
                    headerVisible = true
                }
            }
            .alert("Your Name", isPresented: $showNameEdit) {
                TextField("Enter name", text: $userName)
                Button("Save") {
                    UserDefaults.standard.set(userName, forKey: "user_name")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    // MARK: - Profile Header with Floating Moods

    private var profileHeader: some View {
        ZStack {
            // Floating mood characters
            FloatingMoods()
                .frame(height: 220)
                .opacity(headerVisible ? 1 : 0)

            VStack(spacing: 12) {
                // Avatar
                PhotosPicker(selection: $photoItem, matching: .images) {
                    ZStack {
                        if let img = avatarImage {
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 88, height: 88)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "C7D2FE"), Color(hex: "A5B4FC")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 32))
                                        .foregroundColor(.white)
                                )
                        }

                        // Camera badge
                        Circle()
                            .fill(TH.accent)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: TH.accent.opacity(0.3), radius: 4, y: 2)
                            .offset(x: 32, y: 32)
                    }
                }
                .scaleEffect(headerVisible ? 1 : 0.7)
                .opacity(headerVisible ? 1 : 0)

                // Name
                Button { showNameEdit = true } label: {
                    HStack(spacing: 6) {
                        Text(userName.isEmpty ? "Tap to set name" : userName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(TH.title)

                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(TH.caption)
                    }
                }
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 10)

                // Memory count subtitle
                Text("\(store.tickets.count) memories captured")
                    .font(.system(size: 14))
                    .foregroundColor(TH.caption)
                    .opacity(headerVisible ? 1 : 0)
            }
        }
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
            AnimatedStatCard(
                icon: "ticket.fill",
                value: store.tickets.count,
                label: "Total Memories",
                color: Color(hex: "3B82F6"),
                bgColor: Color(hex: "DBEAFE")
            )
            .stagger(1)

            AnimatedStatCard(
                icon: "flame.fill",
                value: store.streakCount,
                label: "Day Streak",
                color: Color(hex: "F59E0B"),
                bgColor: Color(hex: "FEF3C7")
            )
            .stagger(2)

            AnimatedStatCard(
                icon: "star.fill",
                value: topCategoryCount,
                label: topCategoryName,
                color: Color(hex: "8B5CF6"),
                bgColor: Color(hex: "EDE9FE")
            )
            .stagger(3)

            AnimatedStatCard(
                icon: "calendar",
                value: thisMonthCount,
                label: "This Month",
                color: Color(hex: "10B981"),
                bgColor: Color(hex: "D1FAE5")
            )
            .stagger(3)
        }
    }

    private var topCategoryName: String {
        guard !store.tickets.isEmpty else { return "Top Category" }
        let counts = Dictionary(grouping: store.tickets, by: \.category).mapValues(\.count)
        let top = counts.max(by: { $0.value < $1.value })
        return top?.key.rawValue ?? "Top Category"
    }

    private var topCategoryCount: Int {
        guard !store.tickets.isEmpty else { return 0 }
        let counts = Dictionary(grouping: store.tickets, by: \.category).mapValues(\.count)
        return counts.values.max() ?? 0
    }

    private var thisMonthCount: Int {
        let cal = Calendar.current
        return store.tickets.filter { cal.isDate($0.createdAt, equalTo: Date(), toGranularity: .month) }.count
    }

    // MARK: - Invite Card

    private var inviteCard: some View {
        VStack(spacing: 16) {
            // Mood characters group
            HStack(spacing: -8) {
                MoodFace(mood: .happy, size: 44)
                MoodFace(mood: .loved, size: 44)
                MoodFace(mood: .excited, size: 44)
                MoodFace(mood: .cheerful, size: 44)
            }

            Text("Share the memories!")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(TH.title)

            Text("Invite friends and collect moments together")
                .font(.system(size: 13))
                .foregroundColor(TH.caption)
                .multilineTextAlignment(.center)

            Button {
                shareApp()
            } label: {
                Text("Invite Friends")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "6366F1"), Color(hex: "8B5CF6")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                    )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(TH.card)
                .shadow(color: TH.shadow, radius: 8, y: 3)
        )
    }

    // MARK: - Settings Sections

    private var settingsSections: some View {
        VStack(spacing: 16) {
            // Preferences
            settingsGroup {
                settingsRow(icon: "paintbrush.fill", iconColor: Color(hex: "8B5CF6"), title: "Appearance")
                Divider().padding(.leading, 48)
                settingsRow(icon: "bell.fill", iconColor: Color(hex: "EF4444"), title: "Notifications")
                Divider().padding(.leading, 48)
                settingsRow(icon: "lock.fill", iconColor: Color(hex: "10B981"), title: "Privacy")
            }

            // Data
            settingsGroup {
                settingsRow(icon: "icloud.fill", iconColor: Color(hex: "3B82F6"), title: "Backup & Sync")
                Divider().padding(.leading, 48)
                settingsRow(icon: "square.and.arrow.up.fill", iconColor: Color(hex: "F59E0B"), title: "Export Memories")
                Divider().padding(.leading, 48)
                settingsRow(icon: "arrow.down.circle.fill", iconColor: Color(hex: "6366F1"), title: "Import")
            }

            // About
            settingsGroup {
                settingsRow(icon: "star.fill", iconColor: Color(hex: "FBBF24"), title: "Rate the App")
                Divider().padding(.leading, 48)
                settingsRow(icon: "questionmark.circle.fill", iconColor: Color(hex: "6B7280"), title: "FAQ & Help")
                Divider().padding(.leading, 48)
                settingsRow(icon: "ladybug.fill", iconColor: Color(hex: "EF4444"), title: "Report a Bug")
            }
        }
    }

    private func settingsGroup<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .card()
    }

    private func settingsRow(icon: String, iconColor: Color, title: String) -> some View {
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(iconColor.opacity(0.12))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.system(size: 14))
                        .foregroundColor(iconColor)
                }

                Text(title)
                    .font(.system(size: 15))
                    .foregroundColor(TH.title)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(TH.caption)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - App Info

    private var appInfo: some View {
        VStack(spacing: 6) {
            Text("Memory Ticket")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(TH.caption)
            Text("Version 1.0.0")
                .font(.system(size: 12))
                .foregroundColor(TH.caption.opacity(0.6))
            Text("Made with ❤️")
                .font(.system(size: 12))
                .foregroundColor(TH.caption.opacity(0.6))
                .padding(.top, 2)
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers

    private func shareApp() {
        let text = "Check out Memory Ticket — turn your moments into collectible ticket souvenirs!"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    private func saveAvatar(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar.jpg")
        try? data.write(to: url)
    }

    private func loadAvatar() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("avatar.jpg")
        if let data = try? Data(contentsOf: url) {
            avatarImage = UIImage(data: data)
        }
    }
}

// MARK: - Floating Moods Animation

struct FloatingMoods: View {
    @State private var animate = false

    private let moods: [(MoodType, CGFloat, CGFloat, CGFloat, Double)] = [
        (.happy,     0.12, 0.25, 28, 0.0),
        (.loved,     0.85, 0.18, 24, 0.3),
        (.excited,   0.08, 0.72, 22, 0.6),
        (.cool,      0.88, 0.68, 26, 0.9),
        (.cheerful,  0.72, 0.85, 20, 0.4),
        (.peaceful,  0.25, 0.88, 22, 0.7),
    ]

    var body: some View {
        GeometryReader { geo in
            ForEach(Array(moods.enumerated()), id: \.offset) { i, item in
                let (mood, xPct, yPct, size, delay) = item
                MoodFace(mood: mood, size: size)
                    .offset(
                        x: animate ? CGFloat.random(in: -6...6) : 0,
                        y: animate ? CGFloat.random(in: -10...10) : 0
                    )
                    .position(x: geo.size.width * xPct, y: geo.size.height * yPct)
                    .opacity(animate ? 0.7 : 0)
                    .scaleEffect(animate ? 1 : 0.3)
                    .animation(
                        .easeInOut(duration: Double.random(in: 2.5...3.5))
                        .repeatForever(autoreverses: true)
                        .delay(delay),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Animated Stat Card

struct AnimatedStatCard: View {
    let icon: String
    let value: Int
    let label: String
    let color: Color
    let bgColor: Color

    @State private var displayValue = 0
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(bgColor)
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            Text("\(displayValue)")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(TH.title)
                .contentTransition(.numericText())

            Text(label)
                .font(.system(size: 12))
                .foregroundColor(TH.caption)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(TH.card)
                .shadow(color: TH.shadow, radius: 6, y: 2)
        )
        .onAppear {
            guard !appeared else { return }
            appeared = true
            animateCount()
        }
    }

    private func animateCount() {
        guard value > 0 else { return }
        let steps = min(value, 20)
        let interval = 0.6 / Double(steps)

        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval * Double(i)) {
                withAnimation(.spring(response: 0.2)) {
                    displayValue = Int(Double(value) * Double(i) / Double(steps))
                }
            }
        }
    }
}