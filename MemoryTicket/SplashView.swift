import SwiftUI

struct SplashView: View {
    var onFinished: () -> Void

    @State private var iconScale: CGFloat = 0.4
    @State private var iconOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var ringScale: CGFloat = 0.6
    @State private var ringOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                ZStack {
                    // Pulsing ring
                    Circle()
                        .stroke(TH.accent.opacity(0.15), lineWidth: 2)
                        .frame(width: 130, height: 130)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4F8EF7"), Color(hex: "3478F6")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 88, height: 88)
                            .shadow(color: TH.accent.opacity(0.3), radius: 20, y: 8)

                        Image(systemName: "ticket.fill")
                            .font(.system(size: 36, weight: .medium))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(-15))
                    }
                    .scaleEffect(iconScale)
                    .opacity(iconOpacity)
                }

                VStack(spacing: 6) {
                    Text("Memory Ticket")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(TH.title)

                    Text("collect your moments")
                        .font(.system(size: 15))
                        .foregroundColor(TH.caption)
                }
                .opacity(titleOpacity)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.65).delay(0.15)) {
                iconScale = 1
                iconOpacity = 1
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                ringScale = 1.4
                ringOpacity = 0.6
            }
            withAnimation(.easeOut(duration: 1.2).delay(0.3)) {
                ringOpacity = 0
            }
            withAnimation(.easeOut(duration: 0.5).delay(0.55)) {
                titleOpacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                onFinished()
            }
        }
    }
}
