//
//  MoodType.swift
//  MemoryTicket
//
//  Created by krishna aggarwal on 16/06/26.
//


import SwiftUI

// MARK: - Mood Type

enum MoodType: String, CaseIterable, Identifiable, Codable {
    case happy, loved, excited, peaceful, cheerful, cool, nostalgic, fired

    var id: String { rawValue }

    var label: String {
        switch self {
        case .happy:     return "Happy"
        case .loved:     return "Loved"
        case .excited:   return "Excited"
        case .peaceful:  return "Peaceful"
        case .cheerful:  return "Cheerful"
        case .cool:      return "Cool"
        case .nostalgic: return "Nostalgic"
        case .fired:     return "Fired Up"
        }
    }

    var color: Color {
        switch self {
        case .happy:     return Color(hex: "FBBF24")
        case .loved:     return Color(hex: "F472B6")
        case .excited:   return Color(hex: "FB923C")
        case .peaceful:  return Color(hex: "5EEAD4")
        case .cheerful:  return Color(hex: "4ADE80")
        case .cool:      return Color(hex: "60A5FA")
        case .nostalgic: return Color(hex: "C4B5FD")
        case .fired:     return Color(hex: "F87171")
        }
    }

    var bgColor: Color {
        switch self {
        case .happy:     return Color(hex: "FEF3C7")
        case .loved:     return Color(hex: "FCE7F3")
        case .excited:   return Color(hex: "FFEDD5")
        case .peaceful:  return Color(hex: "CCFBF1")
        case .cheerful:  return Color(hex: "DCFCE7")
        case .cool:      return Color(hex: "DBEAFE")
        case .nostalgic: return Color(hex: "EDE9FE")
        case .fired:     return Color(hex: "FEE2E2")
        }
    }

    static func from(_ string: String) -> MoodType {
        MoodType(rawValue: string) ?? .happy
    }
}

// MARK: - Mood Face View

struct MoodFace: View {
    let mood: MoodType
    var size: CGFloat = 60

    var body: some View {
        ZStack {
            // Blob body
            BlobShape(mood: mood)
                .fill(mood.color)
                .frame(width: size, height: size * blobHeightRatio)

            // Face
            faceOverlay
                .frame(width: size, height: size * blobHeightRatio)
        }
        .frame(width: size, height: size)
    }

    private var blobHeightRatio: CGFloat {
        switch mood {
        case .fired, .excited: return 0.85
        default: return 0.9
        }
    }

    @ViewBuilder
    private var faceOverlay: some View {
        Canvas { ctx, canvasSize in
            let w = canvasSize.width
            let h = canvasSize.height
            let eyeY = h * 0.42
            let mouthY = h * 0.62

            switch mood {
            case .happy:
                // Round eyes
                drawDot(ctx: ctx, x: w * 0.35, y: eyeY, r: w * 0.055, color: .init(hex: "78350F"))
                drawDot(ctx: ctx, x: w * 0.65, y: eyeY, r: w * 0.055, color: .init(hex: "78350F"))
                // Eye shine
                drawDot(ctx: ctx, x: w * 0.37, y: eyeY - w * 0.02, r: w * 0.02, color: .white)
                drawDot(ctx: ctx, x: w * 0.67, y: eyeY - w * 0.02, r: w * 0.02, color: .white)
                // Big smile
                drawArc(ctx: ctx, x: w * 0.5, y: mouthY, radius: w * 0.15, start: 0, end: .pi, color: .init(hex: "78350F"), lineWidth: w * 0.035)

            case .loved:
                // Heart eyes
                drawHeart(ctx: ctx, x: w * 0.33, y: eyeY, size: w * 0.13, color: .init(hex: "BE185D"))
                drawHeart(ctx: ctx, x: w * 0.67, y: eyeY, size: w * 0.13, color: .init(hex: "BE185D"))
                // Gentle smile
                drawArc(ctx: ctx, x: w * 0.5, y: mouthY, radius: w * 0.1, start: 0, end: .pi, color: .init(hex: "9D174D"), lineWidth: w * 0.03)

            case .excited:
                // Wide open eyes
                drawDot(ctx: ctx, x: w * 0.35, y: eyeY, r: w * 0.075, color: .init(hex: "7C2D12"))
                drawDot(ctx: ctx, x: w * 0.65, y: eyeY, r: w * 0.075, color: .init(hex: "7C2D12"))
                drawDot(ctx: ctx, x: w * 0.37, y: eyeY - w * 0.025, r: w * 0.025, color: .white)
                drawDot(ctx: ctx, x: w * 0.67, y: eyeY - w * 0.025, r: w * 0.025, color: .white)
                // Open mouth (O shape)
                drawFilledCircle(ctx: ctx, x: w * 0.5, y: mouthY + w * 0.02, r: w * 0.09, color: .init(hex: "7C2D12"))

            case .peaceful:
                // Closed eyes (happy arcs)
                drawArc(ctx: ctx, x: w * 0.35, y: eyeY, radius: w * 0.06, start: .pi, end: 0, color: .init(hex: "115E59"), lineWidth: w * 0.03)
                drawArc(ctx: ctx, x: w * 0.65, y: eyeY, radius: w * 0.06, start: .pi, end: 0, color: .init(hex: "115E59"), lineWidth: w * 0.03)
                // Gentle smile
                drawArc(ctx: ctx, x: w * 0.5, y: mouthY, radius: w * 0.08, start: 0, end: .pi, color: .init(hex: "115E59"), lineWidth: w * 0.025)

            case .cheerful:
                // Squint happy eyes (^_^)
                drawArc(ctx: ctx, x: w * 0.35, y: eyeY + w * 0.02, radius: w * 0.06, start: .pi + 0.3, end: -0.3, color: .init(hex: "14532D"), lineWidth: w * 0.03)
                drawArc(ctx: ctx, x: w * 0.65, y: eyeY + w * 0.02, radius: w * 0.06, start: .pi + 0.3, end: -0.3, color: .init(hex: "14532D"), lineWidth: w * 0.03)
                // Wide grin
                drawArc(ctx: ctx, x: w * 0.5, y: mouthY - w * 0.02, radius: w * 0.14, start: 0.15, end: .pi - 0.15, color: .init(hex: "14532D"), lineWidth: w * 0.03)

            case .cool:
                // Sunglasses (horizontal lines through eyes)
                let glassY = eyeY - w * 0.01
                var glassPath = Path()
                // Left lens
                glassPath.addRoundedRect(in: CGRect(x: w * 0.2, y: glassY - w * 0.05, width: w * 0.22, height: w * 0.1), cornerSize: CGSize(width: w * 0.04, height: w * 0.04))
                // Right lens
                glassPath.addRoundedRect(in: CGRect(x: w * 0.58, y: glassY - w * 0.05, width: w * 0.22, height: w * 0.1), cornerSize: CGSize(width: w * 0.04, height: w * 0.04))
                // Bridge
                glassPath.move(to: CGPoint(x: w * 0.42, y: glassY))
                glassPath.addLine(to: CGPoint(x: w * 0.58, y: glassY))
                ctx.fill(glassPath, with: .color(Color(hex: "1E3A5F")))
                ctx.stroke(glassPath, with: .color(Color(hex: "1E3A5F")), lineWidth: w * 0.015)
                // Smirk
                var smirk = Path()
                smirk.move(to: CGPoint(x: w * 0.38, y: mouthY))
                smirk.addQuadCurve(to: CGPoint(x: w * 0.62, y: mouthY - w * 0.03), control: CGPoint(x: w * 0.52, y: mouthY + w * 0.06))
                ctx.stroke(smirk, with: .color(Color(hex: "1E3A5F")), lineWidth: w * 0.03)

            case .nostalgic:
                // Soft round eyes
                drawDot(ctx: ctx, x: w * 0.35, y: eyeY, r: w * 0.05, color: .init(hex: "4C1D95"))
                drawDot(ctx: ctx, x: w * 0.65, y: eyeY, r: w * 0.05, color: .init(hex: "4C1D95"))
                drawDot(ctx: ctx, x: w * 0.37, y: eyeY - w * 0.018, r: w * 0.018, color: .white)
                drawDot(ctx: ctx, x: w * 0.67, y: eyeY - w * 0.018, r: w * 0.018, color: .white)
                // Gentle flat smile
                var smile = Path()
                smile.move(to: CGPoint(x: w * 0.38, y: mouthY))
                smile.addQuadCurve(to: CGPoint(x: w * 0.62, y: mouthY), control: CGPoint(x: w * 0.5, y: mouthY + w * 0.06))
                ctx.stroke(smile, with: .color(Color(hex: "4C1D95")), lineWidth: w * 0.025)

            case .fired:
                // Angry determined eyes
                // Left eyebrow (angled down-in)
                var browL = Path()
                browL.move(to: CGPoint(x: w * 0.22, y: eyeY - w * 0.1))
                browL.addLine(to: CGPoint(x: w * 0.42, y: eyeY - w * 0.05))
                ctx.stroke(browL, with: .color(Color(hex: "7F1D1D")), lineWidth: w * 0.035)
                // Right eyebrow
                var browR = Path()
                browR.move(to: CGPoint(x: w * 0.78, y: eyeY - w * 0.1))
                browR.addLine(to: CGPoint(x: w * 0.58, y: eyeY - w * 0.05))
                ctx.stroke(browR, with: .color(Color(hex: "7F1D1D")), lineWidth: w * 0.035)
                // Eyes
                drawDot(ctx: ctx, x: w * 0.35, y: eyeY + w * 0.02, r: w * 0.05, color: .init(hex: "7F1D1D"))
                drawDot(ctx: ctx, x: w * 0.65, y: eyeY + w * 0.02, r: w * 0.05, color: .init(hex: "7F1D1D"))
                // Determined mouth
                drawArc(ctx: ctx, x: w * 0.5, y: mouthY + w * 0.06, radius: w * 0.1, start: .pi, end: 0, color: .init(hex: "7F1D1D"), lineWidth: w * 0.03)
            }
        }
    }

    // MARK: - Drawing Helpers

    private func drawDot(ctx: GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, color: Color) {
        ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(color))
    }

    private func drawFilledCircle(ctx: GraphicsContext, x: CGFloat, y: CGFloat, r: CGFloat, color: Color) {
        ctx.fill(Path(ellipseIn: CGRect(x: x - r, y: y - r, width: r * 2, height: r * 2)), with: .color(color))
    }

    private func drawArc(ctx: GraphicsContext, x: CGFloat, y: CGFloat, radius: CGFloat, start: CGFloat, end: CGFloat, color: Color, lineWidth: CGFloat) {
        var path = Path()
        path.addArc(center: CGPoint(x: x, y: y), radius: radius, startAngle: .radians(start), endAngle: .radians(end), clockwise: false)
        ctx.stroke(path, with: .color(color), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
    }

    private func drawHeart(ctx: GraphicsContext, x: CGFloat, y: CGFloat, size: CGFloat, color: Color) {
        var path = Path()
        let s = size
        path.move(to: CGPoint(x: x, y: y + s * 0.35))
        path.addCurve(
            to: CGPoint(x: x, y: y - s * 0.25),
            control1: CGPoint(x: x - s * 0.55, y: y + s * 0.1),
            control2: CGPoint(x: x - s * 0.5, y: y - s * 0.45)
        )
        path.addCurve(
            to: CGPoint(x: x, y: y + s * 0.35),
            control1: CGPoint(x: x + s * 0.5, y: y - s * 0.45),
            control2: CGPoint(x: x + s * 0.55, y: y + s * 0.1)
        )
        ctx.fill(path, with: .color(color))
    }
}

// MARK: - Blob Shape

struct BlobShape: Shape {
    let mood: MoodType

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        switch mood {
        case .fired, .excited:
            // Mountain/peaked blob (like the angry reference)
            path.move(to: CGPoint(x: w * 0.05, y: h))
            path.addCurve(
                to: CGPoint(x: w * 0.5, y: h * 0.05),
                control1: CGPoint(x: w * 0.0, y: h * 0.4),
                control2: CGPoint(x: w * 0.2, y: h * 0.05)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.95, y: h),
                control1: CGPoint(x: w * 0.8, y: h * 0.05),
                control2: CGPoint(x: w * 1.0, y: h * 0.4)
            )
            path.addLine(to: CGPoint(x: w * 0.05, y: h))

        case .peaceful, .nostalgic:
            // Soft wide blob
            path.move(to: CGPoint(x: w * 0.02, y: h))
            path.addCurve(
                to: CGPoint(x: w * 0.98, y: h),
                control1: CGPoint(x: w * -0.05, y: h * 0.15),
                control2: CGPoint(x: w * 1.05, y: h * 0.15)
            )
            path.addLine(to: CGPoint(x: w * 0.02, y: h))

        default:
            // Standard rounded blob
            path.move(to: CGPoint(x: w * 0.03, y: h))
            path.addCurve(
                to: CGPoint(x: w * 0.5, y: h * 0.08),
                control1: CGPoint(x: w * -0.02, y: h * 0.25),
                control2: CGPoint(x: w * 0.15, y: h * 0.08)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.97, y: h),
                control1: CGPoint(x: w * 0.85, y: h * 0.08),
                control2: CGPoint(x: w * 1.02, y: h * 0.25)
            )
            path.addLine(to: CGPoint(x: w * 0.03, y: h))
        }

        return path
    }
}

// MARK: - Mood Picker Cell

struct MoodPickerCell: View {
    let mood: MoodType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                MoodFace(mood: mood, size: 56)
                    .scaleEffect(isSelected ? 1.1 : 1)

                Text(mood.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(isSelected ? TH.title : TH.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(isSelected ? mood.bgColor : TH.bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? mood.color.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Small Mood Badge (for cards/rows)

struct MoodBadge: View {
    let mood: MoodType
    var size: CGFloat = 32

    var body: some View {
        MoodFace(mood: mood, size: size)
            .padding(4)
            .background(
                Circle()
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
            )
    }
}