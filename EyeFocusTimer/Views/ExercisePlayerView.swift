import SwiftUI

struct ExercisePlayerView: View {
    @EnvironmentObject var m: EyeManager
    @Environment(\.dismiss) var dismiss
    let exercise: EyeExercise
    @State private var timeLeft: Int = 0
    @State private var isRunning = false
    @State private var finished = false
    @State private var timer: Timer?

    // Follow Dot
    @State private var dotX: CGFloat = 0.5
    @State private var dotY: CGFloat = 0.5
    @State private var dotPhase: Double = 0

    // Near-Far
    @State private var focusNear = true
    @State private var focusSwitches = 0

    // Palming
    @State private var breatheIn = true

    // Blink
    @State private var blinkCount = 0
    @State private var showBlink = false

    // Peripheral
    @State private var periDotPos: CGPoint = .init(x: 0.5, y: 0.5)
    @State private var periVisible = false
    @State private var periHits = 0
    @State private var periTotal = 0

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar
                if finished { finishedView } else if !isRunning { preView } else { exerciseContent }
            }
        }.onDisappear { timer?.invalidate() }
    }

    private var topBar: some View {
        HStack {
            Button { timer?.invalidate(); dismiss() } label: {
                Image(systemName: "xmark.circle.fill").font(.system(size: 28)).foregroundStyle(Theme.dim)
            }; Spacer()
            if isRunning && !finished {
                Text("\(timeLeft)s").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(Theme.text).monospacedDigit()
                    .padding(.horizontal, 16).padding(.vertical, 6).background(Theme.surface).clipShape(Capsule(style: .continuous))
            }; Spacer(); Color.clear.frame(width: 28)
        }.padding(.horizontal, 20).padding(.top, 12)
    }

    // MARK: - Pre
    private var preView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: exercise.icon).font(.system(size: 56)).foregroundStyle(exercise.color)
                .shadow(color: exercise.color.opacity(0.4), radius: 15)
            Text(exercise.name).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
            Text(exercise.description).font(.system(size: 14, design: .rounded)).foregroundColor(Theme.sub).multilineTextAlignment(.center).lineSpacing(3).padding(.horizontal, 30)
            Text("\(exercise.duration) seconds").font(.system(size: 16, weight: .semibold, design: .rounded)).foregroundColor(exercise.color)
            Spacer()
            Button { startExercise() } label: {
                HStack(spacing: 8) { Image(systemName: "play.fill"); Text("Start").font(.system(size: 17, weight: .bold, design: .rounded)) }
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(exercise.color.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: exercise.color.opacity(0.3), radius: 10, y: 4)
            }.padding(.horizontal, 30).padding(.bottom, 40)
        }
    }

    // MARK: - Finished
    private var finishedView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill").font(.system(size: 60)).foregroundStyle(Theme.mint)
                .shadow(color: Theme.mint.opacity(0.4), radius: 15)
            Text("Exercise Complete!").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
            if exercise.id == .peripheralPeek {
                let score = periTotal > 0 ? Int(Double(periHits) / Double(periTotal) * 100) : 0
                Text("Score: \(score)% (\(periHits)/\(periTotal))").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(Theme.violet)
            }
            if exercise.id == .blinkBreak { Text("\(blinkCount) blinks").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(Theme.violet) }
            if exercise.id == .nearFar { Text("\(focusSwitches) focus shifts").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(Theme.violet) }
            Spacer()
            Button { dismiss() } label: {
                HStack(spacing: 8) { Image(systemName: "checkmark"); Text("Done").font(.system(size: 17, weight: .bold, design: .rounded)) }
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Theme.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }.padding(.horizontal, 30).padding(.bottom, 40)
        }
    }

    // MARK: - Content Router
    @ViewBuilder private var exerciseContent: some View {
        switch exercise.id {
        case .followDot: followDotView
        case .nearFar: nearFarView
        case .palming: palmingView
        case .figure8: figure8View
        case .blinkBreak: blinkView
        case .peripheralPeek: peripheralView
        }
    }

    // MARK: - Follow Dot
    private var followDotView: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height
            ZStack {
                Text("Follow the dot with your eyes.\nDon't move your head.")
                    .font(.system(size: 13, design: .rounded)).foregroundColor(Theme.dim).multilineTextAlignment(.center)
                    .position(x: w / 2, y: 40)
                PulseDot(color: exercise.color, size: 24)
                    .position(x: dotX * w, y: dotY * h)
            }
        }
    }

    // MARK: - Near-Far
    private var nearFarView: some View {
        VStack(spacing: 30) {
            Spacer()
            Text(focusNear ? "FOCUS NEAR" : "FOCUS FAR").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Theme.sub).tracking(2)
            ZStack {
                Circle().stroke(Theme.dim, lineWidth: 2).frame(width: 200, height: 200)
                Circle().fill(focusNear ? exercise.color : exercise.color.opacity(0.15))
                    .frame(width: focusNear ? 40 : 180, height: focusNear ? 40 : 180)
                    .shadow(color: exercise.color.opacity(focusNear ? 0.6 : 0.2), radius: focusNear ? 15 : 5)
                    .animation(.easeInOut(duration: 0.8), value: focusNear)
            }
            Text("Hold your thumb 15cm from your face.\nAlternate focus between thumb and screen edge.")
                .font(.system(size: 12, design: .rounded)).foregroundColor(Theme.dim).multilineTextAlignment(.center)
            Text("\(focusSwitches) shifts").font(.system(size: 16, weight: .bold, design: .rounded)).foregroundColor(exercise.color)
            Spacer()
        }.padding(.horizontal, 20)
    }

    // MARK: - Palming
    private var palmingView: some View {
        VStack(spacing: 20) {
            Spacer()
            Text(breatheIn ? "Inhale..." : "Exhale...").font(.system(size: 18, weight: .medium, design: .rounded)).foregroundColor(Theme.sub)
                .animation(.easeInOut, value: breatheIn)
            ZStack {
                Circle().fill(Theme.violet.opacity(breatheIn ? 0.08 : 0.02)).frame(width: breatheIn ? 250 : 150, height: breatheIn ? 250 : 150)
                    .animation(.easeInOut(duration: 4), value: breatheIn)
                Circle().fill(Theme.violet.opacity(0.15)).frame(width: breatheIn ? 120 : 60, height: breatheIn ? 120 : 60)
                    .animation(.easeInOut(duration: 4), value: breatheIn)
                Image(systemName: "hand.raised.fill").font(.system(size: 36)).foregroundStyle(Theme.violet.opacity(0.5))
            }
            Text("Cover your eyes with your palms.\nRelax and breathe deeply.")
                .font(.system(size: 13, design: .rounded)).foregroundColor(Theme.dim).multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Figure 8
    private var figure8View: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height
            let cx = w / 2; let cy = h / 2
            let rx = w * 0.35; let ry = h * 0.15
            let x = cx + rx * Foundation.cos(dotPhase)
            let y = cy + ry * Foundation.sin(dotPhase * 2)
            ZStack {
                Text("Follow the dot tracing ∞").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.dim).position(x: cx, y: 40)
                infinityPath(cx: cx, cy: cy, rx: rx, ry: ry)
                    .stroke(Theme.dim, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
                PulseDot(color: exercise.color, size: 22).position(x: x, y: y)
            }
        }
    }

    private func infinityPath(cx: CGFloat, cy: CGFloat, rx: CGFloat, ry: CGFloat) -> Path {
        var p = Path()
        for i in 0...200 {
            let t = Double(i) / 200.0 * Double.pi * 2
            let x = cx + rx * Foundation.cos(t)
            let y = cy + ry * Foundation.sin(t * 2)
            if i == 0 { p.move(to: CGPoint(x: x, y: y)) } else { p.addLine(to: CGPoint(x: x, y: y)) }
        }; return p
    }

    // MARK: - Blink
    private var blinkView: some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(showBlink ? exercise.color.opacity(0.15) : Theme.surface).frame(width: 160, height: 160)
                    .animation(.easeInOut(duration: 0.3), value: showBlink)
                Image(systemName: showBlink ? "eye.slash.fill" : "eye.fill").font(.system(size: 52))
                    .foregroundStyle(showBlink ? exercise.color : Theme.dim)
                    .animation(.easeInOut(duration: 0.3), value: showBlink)
            }
            Text(showBlink ? "BLINK!" : "Open").font(.system(size: 28, weight: .bold, design: .rounded)).foregroundColor(showBlink ? exercise.color : Theme.sub)
            Text("\(blinkCount) blinks").font(.system(size: 18, weight: .semibold, design: .rounded)).foregroundColor(exercise.color)
            Text("Blink fully — close and open.\nEncourages a healthy blink rate.")
                .font(.system(size: 12, design: .rounded)).foregroundColor(Theme.dim).multilineTextAlignment(.center)
            Spacer()
        }
    }

    // MARK: - Peripheral
    private var peripheralView: some View {
        GeometryReader { geo in
            let w = geo.size.width; let h = geo.size.height
            ZStack {
                PulseDot(color: Theme.cyan, size: 12).position(x: w / 2, y: h / 2)
                Text("Stare at center. Tap when you see a flash.")
                    .font(.system(size: 12, design: .rounded)).foregroundColor(Theme.dim).position(x: w / 2, y: 40)
                if periVisible {
                    Circle().fill(Theme.amber).frame(width: 18, height: 18).shadow(color: Theme.amber.opacity(0.8), radius: 8)
                        .position(x: periDotPos.x * w, y: periDotPos.y * h)
                        .transition(.opacity)
                }
                Text("Hits: \(periHits)/\(periTotal)").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Theme.amber)
                    .position(x: w / 2, y: h - 40)
            }.contentShape(Rectangle())
            .onTapGesture {
                if periVisible { periHits += 1; withAnimation { periVisible = false } }
            }
        }
    }

    // MARK: - Engine
    private func startExercise() {
        timeLeft = exercise.duration; isRunning = true; finished = false
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: exercise.id == .followDot || exercise.id == .figure8 ? 0.03 : 1.0, repeats: true) { _ in tick() }
    }

    private func tick() {
        let dt: Double = exercise.id == .followDot || exercise.id == .figure8 ? 0.03 : 1.0

        switch exercise.id {
        case .followDot:
            dotPhase += dt * 1.5
            dotX = 0.5 + 0.35 * Foundation.cos(dotPhase)
            dotY = 0.5 + 0.25 * Foundation.sin(dotPhase * 0.7)
            timeLeft = max(exercise.duration - Int(dotPhase / 1.5), 0)
            if timeLeft <= 0 { finish() }

        case .figure8:
            dotPhase += dt * 1.8
            timeLeft = max(exercise.duration - Int(dotPhase / 1.8), 0)
            if timeLeft <= 0 { finish() }

        case .nearFar:
            timeLeft -= 1
            if timeLeft % 3 == 0 { focusNear.toggle(); focusSwitches += 1; if m.hapticEnabled { UIImpactFeedbackGenerator(style: .light).impactOccurred() } }
            if timeLeft <= 0 { finish() }

        case .palming:
            timeLeft -= 1
            if timeLeft % 4 == 0 { breatheIn.toggle() }
            if timeLeft <= 0 { finish() }

        case .blinkBreak:
            timeLeft -= 1
            let shouldBlink = timeLeft % 2 == 0
            if showBlink != shouldBlink { showBlink = shouldBlink; if shouldBlink { blinkCount += 1 } }
            if timeLeft <= 0 { finish() }

        case .peripheralPeek:
            timeLeft -= 1
            if timeLeft % 3 == 0 && timeLeft > 2 {
                periTotal += 1
                let edge = Int.random(in: 0...3)
                switch edge {
                case 0: periDotPos = CGPoint(x: CGFloat.random(in: 0.05...0.2), y: CGFloat.random(in: 0.2...0.8))
                case 1: periDotPos = CGPoint(x: CGFloat.random(in: 0.8...0.95), y: CGFloat.random(in: 0.2...0.8))
                case 2: periDotPos = CGPoint(x: CGFloat.random(in: 0.2...0.8), y: CGFloat.random(in: 0.08...0.2))
                default: periDotPos = CGPoint(x: CGFloat.random(in: 0.2...0.8), y: CGFloat.random(in: 0.8...0.92))
                }
                withAnimation(.easeIn(duration: 0.15)) { periVisible = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { withAnimation { self.periVisible = false } }
            }
            if timeLeft <= 0 { finish() }
        }
    }

    private func finish() {
        timer?.invalidate(); isRunning = true; finished = true
        let score = exercise.id == .peripheralPeek && periTotal > 0 ? Int(Double(periHits) / Double(periTotal) * 100) : nil
        m.logExercise(exercise.id, duration: exercise.duration, score: score)
        if m.hapticEnabled { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    }
}
