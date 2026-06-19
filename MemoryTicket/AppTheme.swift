import SwiftUI

// MARK: - Theme

struct TH {
    // Backgrounds
    static let bg = Color(hex: "F2F2F7")
    static let card = Color.white
    static let cardHover = Color(hex: "F9FAFB")

    // Text
    static let title = Color(hex: "111827")
    static let body = Color(hex: "374151")
    static let caption = Color(hex: "9CA3AF")

    // Accent
    static let accent = Color(hex: "3478F6")
    static let accentLight = Color(hex: "EFF6FF")

    // Shadows
    static let shadow = Color.black.opacity(0.06)
    static let shadowMd = Color.black.opacity(0.1)
}

// MARK: - Card Style

struct CardStyle: ViewModifier {
    var padding: CGFloat = 0
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(TH.card)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: TH.shadow, radius: 8, y: 2)
    }
}
extension View {
    func card(padding: CGFloat = 0) -> some View { modifier(CardStyle(padding: padding)) }
}

// MARK: - Stagger Animation

struct StaggerIn: ViewModifier {
    let index: Int
    @State private var show = false
    func body(content: Content) -> some View {
        content
            .opacity(show ? 1 : 0)
            .offset(y: show ? 0 : 24)
            .onAppear {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75).delay(Double(index) * 0.06)) {
                    show = true
                }
            }
    }
}
extension View {
    func stagger(_ i: Int) -> some View { modifier(StaggerIn(index: i)) }
}

// MARK: - Ticket Shape (perforated sides)

struct TicketShape: Shape {
    var notchRadius: CGFloat = 14
    var notchPosition: CGFloat = 0.58

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let cr: CGFloat = 18
        let nr = notchRadius
        let midY = rect.height * notchPosition

        p.move(to: CGPoint(x: 0, y: cr))
        p.addQuadCurve(to: CGPoint(x: cr, y: 0), control: .zero)
        p.addLine(to: CGPoint(x: rect.maxX - cr, y: 0))
        p.addQuadCurve(to: CGPoint(x: rect.maxX, y: cr), control: CGPoint(x: rect.maxX, y: 0))

        p.addLine(to: CGPoint(x: rect.maxX, y: midY - nr))
        p.addArc(center: CGPoint(x: rect.maxX, y: midY), radius: nr, startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - cr))
        p.addQuadCurve(to: CGPoint(x: rect.maxX - cr, y: rect.maxY), control: CGPoint(x: rect.maxX, y: rect.maxY))

        p.addLine(to: CGPoint(x: cr, y: rect.maxY))
        p.addQuadCurve(to: CGPoint(x: 0, y: rect.maxY - cr), control: CGPoint(x: 0, y: rect.maxY))
        p.addLine(to: CGPoint(x: 0, y: midY + nr))
        p.addArc(center: CGPoint(x: 0, y: midY), radius: nr, startAngle: .degrees(90), endAngle: .degrees(-90), clockwise: true)

        p.closeSubpath()
        return p
    }
}

// MARK: - Dotted Perforation

struct DottedLine: View {
    var color: Color = Color(hex: "D1D5DB")
    var body: some View {
        GeometryReader { geo in
            Path { path in
                var x: CGFloat = 0
                while x < geo.size.width {
                    path.addEllipse(in: CGRect(x: x, y: 0, width: 4, height: 4))
                    x += 10
                }
            }
            .fill(color)
        }
        .frame(height: 4)
    }
}

// MARK: - Date Badge

struct DateBadge: View {
    let text: String
    var color: Color = .white

    var body: some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .foregroundColor(color == .white ? TH.title : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(
                Capsule()
                    .fill(color)
                    .shadow(color: .black.opacity(0.15), radius: 4, y: 1)
            )
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    @State private var bounce = false

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 48, weight: .light))
                .foregroundColor(TH.caption)
                .offset(y: bounce ? -6 : 0)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: bounce)

            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(TH.title)

            Text(subtitle)
                .font(.system(size: 14))
                .foregroundColor(TH.caption)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 240)
        }
        .onAppear { bounce = true }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
