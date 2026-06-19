//
//  OnboardingView.swift
//  MemoryTicket
//
//  Created by krishna aggarwal on 19/06/26.
//


import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void
    @State private var page = 0
    @State private var userName = ""
    @State private var selectedMood: MoodType = .happy

    var body: some View {
        ZStack {
            // Dynamic background color
            pageBackground
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.6), value: page)

            VStack(spacing: 0) {
                // Skip button
                HStack {
                    Spacer()
                    if page < 2 {
                        Button {
                            withAnimation { onComplete() }
                        } label: {
                            Text("Skip")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(TH.caption)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                // Pages
                TabView(selection: $page) {
                    WelcomePage().tag(0)
                    HowItWorksPage().tag(1)
                    GetStartedPage(
                        userName: $userName,
                        selectedMood: $selectedMood,
                        onComplete: onComplete
                    ).tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: page)

                // Bottom section
                bottomSection
            }
        }
    }

    // MARK: - Background

    private var pageBackground: some View {
        Group {
            switch page {
            case 0:
                LinearGradient(
                    colors: [Color(hex: "EEF2FF"), Color(hex: "F0F9FF"), Color.white],
                    startPoint: .top, endPoint: .bottom
                )
            case 1:
                LinearGradient(
                    colors: [Color(hex: "FFF7ED"), Color(hex: "FFFBEB"), Color.white],
                    startPoint: .top, endPoint: .bottom
                )
            default:
                LinearGradient(
                    colors: [selectedMood.bgColor, Color.white],
                    startPoint: .top, endPoint: .bottom
                )
            }
        }
    }

    // MARK: - Bottom

    private var bottomSection: some View {
        VStack(spacing: 16) {
            // Page dots
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { i in
                    Capsule()
                        .fill(i == page ? TH.accent : Color(hex: "D1D5DB"))
                        .frame(width: i == page ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.35), value: page)
                }
            }

            if page < 2 {
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.8)) {
                        page += 1
                    }
                } label: {
                    Text("Next")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            Capsule().fill(TH.accent)
                        )
                }
                .padding(.horizontal, 30)
            }

            Spacer().frame(height: 20)
        }
    }
}

// MARK: - Page 1: Welcome with Character Cluster

struct WelcomePage: View {
    @State private var appeared = false
    @State private var floating = false

    private let characters: [(MoodType, CGFloat, CGFloat, CGFloat, Double)] = [
        (.happy,     0.50, 0.32, 90,  0.0),    // center top — big
        (.loved,     0.22, 0.22, 55,  0.15),   // top left
        (.excited,   0.78, 0.25, 60,  0.25),   // top right
        (.cool,      0.18, 0.55, 70,  0.35),   // mid left
        (.cheerful,  0.82, 0.52, 65,  0.20),   // mid right
        (.peaceful,  0.35, 0.62, 50,  0.40),   // bottom left
        (.nostalgic, 0.65, 0.65, 45,  0.30),   // bottom right
        (.fired,     0.50, 0.72, 40,  0.45),   // bottom center — small
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Character cluster area
            GeometryReader { geo in
                ZStack {
                    ForEach(Array(characters.enumerated()), id: \.offset) { i, item in
                        let (mood, xPct, yPct, size, delay) = item

                        MoodFace(mood: mood, size: size)
                            .shadow(color: mood.color.opacity(0.3), radius: 12, y: 6)
                            .offset(
                                y: floating ? (i % 2 == 0 ? -6 : 6) : 0
                            )
                            .position(
                                x: geo.size.width * xPct,
                                y: geo.size.height * yPct
                            )
                            .scaleEffect(appeared ? 1 : 0.1)
                            .opacity(appeared ? 1 : 0)
                            .animation(
                                .spring(response: 0.6, dampingFraction: 0.55)
                                .delay(delay),
                                value: appeared
                            )
                            .animation(
                                .easeInOut(duration: Double.random(in: 2.0...3.0))
                                .repeatForever(autoreverses: true)
                                .delay(delay),
                                value: floating
                            )
                    }

                    // Speech bubble
                    SpeechBubble(text: "Hello~")
                        .position(x: geo.size.width * 0.58, y: geo.size.height * 0.48)
                        .scaleEffect(appeared ? 1 : 0)
                        .opacity(appeared ? 1 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.6), value: appeared)
                }
            }
            .frame(height: 380)

            // Text
            VStack(spacing: 12) {
                Text("Memory Ticket")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(TH.title)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.easeOut(duration: 0.5).delay(0.5), value: appeared)

                Text("Turn your moments into\ncollectible memories")
                    .font(.system(size: 16))
                    .foregroundColor(TH.caption)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)
                    .animation(.easeOut(duration: 0.5).delay(0.65), value: appeared)
            }

            Spacer()
        }
        .onAppear {
            appeared = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                floating = true
            }
        }
    }
}

// MARK: - Speech Bubble

struct SpeechBubble: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                ZStack {
                    Capsule().fill(Color(hex: "374151"))

                    // Tail
                    Triangle()
                        .fill(Color(hex: "374151"))
                        .frame(width: 14, height: 10)
                        .rotationEffect(.degrees(180))
                        .offset(x: -10, y: 18)
                }
            )
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.midX, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Page 2: How It Works

struct HowItWorksPage: View {
    @State private var appeared = false
    @State private var cardRotation: Double = 12
    @State private var showSteps = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer().frame(height: 20)

            // Animated ticket preview
            ZStack {
                // Background card (rotated)
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(hex: "FED7AA"))
                    .frame(width: 240, height: 300)
                    .rotationEffect(.degrees(appeared ? -6 : -15))
                    .offset(x: -12)
                    .opacity(appeared ? 0.6 : 0)

                // Foreground ticket card
                VStack(spacing: 0) {
                    // Photo placeholder
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "93C5FD"), Color(hex: "BFDBFE")],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 140)

                        Image(systemName: "photo.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    .padding(12)

                    DottedLine(color: Color(hex: "E5E7EB"))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Summer Trip")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(TH.title)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin").font(.system(size: 10))
                            Text("Goa Beach").font(.system(size: 12))
                        }
                        .foregroundColor(TH.caption)

                        HStack(spacing: 4) {
                            Image(systemName: "calendar").font(.system(size: 10))
                            Text("June 15, 2026").font(.system(size: 12))
                        }
                        .foregroundColor(TH.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
                .frame(width: 240)
                .background(TH.card)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: TH.shadowMd, radius: 20, y: 8)
                .rotationEffect(.degrees(appeared ? 2 : 12))
                .scaleEffect(appeared ? 1 : 0.8)
                .opacity(appeared ? 1 : 0)

                // Mood badge
                MoodFace(mood: .excited, size: 44)
                    .shadow(color: MoodType.excited.color.opacity(0.3), radius: 8, y: 4)
                    .offset(x: 110, y: -120)
                    .scaleEffect(appeared ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.5).delay(0.5), value: appeared)
            }
            .frame(height: 320)

            // Steps
            VStack(spacing: 20) {
                Text("How it works")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(TH.title)
                    .opacity(showSteps ? 1 : 0)
                    .offset(y: showSteps ? 0 : 15)

                HStack(spacing: 20) {
                    StepItem(icon: "camera.fill", label: "Capture", delay: 0.1, show: showSteps)
                    StepItem(icon: "sparkles", label: "Create", delay: 0.2, show: showSteps)
                    StepItem(icon: "square.grid.2x2.fill", label: "Collect", delay: 0.3, show: showSteps)
                }
            }

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.1)) {
                appeared = true
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.4)) {
                showSteps = true
            }
        }
    }
}

struct StepItem: View {
    let icon: String
    let label: String
    let delay: Double
    let show: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(TH.accentLight)
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(TH.accent)
            }

            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(TH.body)
        }
        .opacity(show ? 1 : 0)
        .offset(y: show ? 0 : 20)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(delay), value: show)
    }
}

// MARK: - Page 3: Get Started

struct GetStartedPage: View {
    @Binding var userName: String
    @Binding var selectedMood: MoodType
    var onComplete: () -> Void

    @State private var appeared = false
    @State private var characterBounce = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer().frame(height: 10)

            // Large animated mood character
            ZStack {
                // Glow
                Circle()
                    .fill(selectedMood.color.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 30)
                    .scaleEffect(characterBounce ? 1.1 : 0.9)

                MoodFace(mood: selectedMood, size: 140)
                    .shadow(color: selectedMood.color.opacity(0.3), radius: 16, y: 8)
                    .scaleEffect(appeared ? 1 : 0.3)
                    .offset(y: characterBounce ? -4 : 4)
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.5), value: selectedMood)
            .animation(
                .easeInOut(duration: 1.8).repeatForever(autoreverses: true),
                value: characterBounce
            )
            .frame(height: 200)

            VStack(spacing: 8) {
                Text("How are you\nfeeling today?")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(TH.title)
                    .multilineTextAlignment(.center)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 15)

                Text("Select the mood that fits best")
                    .font(.system(size: 14))
                    .foregroundColor(TH.caption)
                    .opacity(appeared ? 1 : 0)
            }

            // Mood pills (horizontal scroll)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MoodType.allCases) { mood in
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                selectedMood = mood
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            HStack(spacing: 6) {
                                MoodFace(mood: mood, size: 22)
                                Text(mood.label)
                                    .font(.system(size: 13, weight: selectedMood == mood ? .bold : .medium))
                            }
                            .foregroundColor(selectedMood == mood ? .white : TH.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(selectedMood == mood ? selectedMood.color : TH.card)
                                    .shadow(color: selectedMood == mood ? selectedMood.color.opacity(0.3) : TH.shadow, radius: 6, y: 2)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .opacity(appeared ? 1 : 0)

            // Name input
            VStack(alignment: .leading, spacing: 6) {
                Text("What should we call you?")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(TH.caption)

                TextField("Your name", text: $userName)
                    .font(.system(size: 16))
                    .foregroundColor(TH.title)
                    .padding(14)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(TH.card)
                            .shadow(color: TH.shadow, radius: 4, y: 1)
                    )
            }
            .padding(.horizontal, 30)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)

            // Start button
            Button {
                if !userName.isEmpty {
                    UserDefaults.standard.set(userName, forKey: "user_name")
                }
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                onComplete()
            } label: {
                HStack(spacing: 8) {
                    Text("Start Your Journey")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [selectedMood.color, selectedMood.color.opacity(0.8)],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .shadow(color: selectedMood.color.opacity(0.3), radius: 8, y: 4)
                )
            }
            .padding(.horizontal, 30)
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 20)
            .animation(.spring(response: 0.3), value: selectedMood)

            Spacer()
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.1)) {
                appeared = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                characterBounce = true
            }
        }
    }
}