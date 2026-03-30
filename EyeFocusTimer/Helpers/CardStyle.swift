import SwiftUI

struct Theme {
    static let bg      = Color(red: 0.02, green: 0.02, blue: 0.07)
    static let surface = Color(red: 0.06, green: 0.06, blue: 0.13)
    static let card    = Color.white.opacity(0.04)
    static let border  = Color.white.opacity(0.07)

    static let cyan   = Color(red: 0.20, green: 0.78, blue: 0.98)
    static let violet = Color(red: 0.55, green: 0.35, blue: 0.92)
    static let mint   = Color(red: 0.30, green: 0.88, blue: 0.65)
    static let amber  = Color(red: 0.95, green: 0.72, blue: 0.22)
    static let rose   = Color(red: 0.90, green: 0.35, blue: 0.45)

    static let text = Color.white.opacity(0.92)
    static let sub  = Color.white.opacity(0.50)
    static let dim  = Color.white.opacity(0.22)

    static let gradient    = LinearGradient(colors: [cyan, violet], startPoint: .topLeading, endPoint: .bottomTrailing)
    static let cyanGrad    = LinearGradient(colors: [cyan, cyan.opacity(0.5)], startPoint: .top, endPoint: .bottom)
    static let violetGrad  = LinearGradient(colors: [violet, violet.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
}

struct GlassCard: ViewModifier {
    var pad: CGFloat = 16; var rad: CGFloat = 20
    func body(content: Content) -> some View {
        content.padding(pad)
            .background(.ultraThinMaterial.opacity(0.2))
            .background(Theme.card)
            .clipShape(RoundedRectangle(cornerRadius: rad, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: rad, style: .continuous).stroke(Theme.border, lineWidth: 1))
    }
}

struct AccentCard: ViewModifier {
    let color: Color; var pad: CGFloat = 16
    func body(content: Content) -> some View {
        content.padding(pad)
            .background(color.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(color.opacity(0.18), lineWidth: 1))
    }
}

extension View {
    func glassCard(pad: CGFloat = 16, rad: CGFloat = 20) -> some View { modifier(GlassCard(pad: pad, rad: rad)) }
    func accentCard(_ c: Color, pad: CGFloat = 16) -> some View { modifier(AccentCard(color: c, pad: pad)) }
}

// MARK: - Countdown Ring

struct CountdownRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 8
    var size: CGFloat = 200

    var body: some View {
        ZStack {
            Circle().stroke(Theme.dim, lineWidth: lineWidth).frame(width: size, height: size)
            Circle().trim(from: 0, to: progress)
                .stroke(AngularGradient(colors: [color.opacity(0.3), color], center: .center), style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .frame(width: size, height: size).rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.4), radius: 8)
        }
    }
}

// MARK: - Pulse Dot

struct PulseDot: View {
    let color: Color; var size: CGFloat = 20
    @State private var pulse = false
    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.15)).frame(width: size * 2.5, height: size * 2.5).scaleEffect(pulse ? 1.3 : 0.8).opacity(pulse ? 0 : 0.6)
            Circle().fill(color).frame(width: size, height: size).shadow(color: color.opacity(0.6), radius: 10)
        }.onAppear { withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) { pulse = true } }
    }
}

// MARK: - Simple Bar Chart

struct MiniBarChart: View {
    let data: [Double]; let color: Color
    var body: some View {
        GeometryReader { geo in
            let maxV = max(data.max() ?? 1, 1)
            HStack(alignment: .bottom, spacing: 3) {
                ForEach(Array(data.enumerated()), id: \.offset) { i, v in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(i == data.count - 1 ? color : color.opacity(0.4))
                        .frame(height: max(CGFloat(v / maxV) * geo.size.height, 4))
                }
            }
        }
    }
}
