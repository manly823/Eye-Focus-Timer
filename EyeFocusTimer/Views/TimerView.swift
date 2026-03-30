import SwiftUI

struct TimerView: View {
    @EnvironmentObject var m: EyeManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                header
                switch m.timerPhase {
                case .idle: idleView
                case .working: workingView
                case .breakTime: breakView
                case .exercisePrompt: promptView
                }
                todaySummary
            }.padding(.horizontal, 16).padding(.bottom, 40)
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Eye Focus Timer").font(.system(size: 22, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                Text("Protect your vision").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub)
            }; Spacer()
            HStack(spacing: 4) {
                Image(systemName: "flame.fill").font(.system(size: 13)).foregroundColor(Theme.amber)
                Text("\(m.currentStreak)d").font(.system(size: 14, weight: .bold, design: .rounded)).foregroundColor(Theme.amber)
            }.padding(.horizontal, 12).padding(.vertical, 6).background(Theme.amber.opacity(0.1)).clipShape(Capsule(style: .continuous))
        }.padding(.top, 8)
    }

    // MARK: - Idle
    private var idleView: some View {
        VStack(spacing: 24) {
            ZStack {
                CountdownRing(progress: 1.0, color: Theme.cyan, lineWidth: 10, size: 220)
                    .opacity(0.3)
                VStack(spacing: 4) {
                    Image(systemName: "eye.fill").font(.system(size: 32)).foregroundStyle(Theme.gradient)
                    Text(formatTime(m.interval.seconds)).font(.system(size: 44, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                    Text("Ready").font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(Theme.sub)
                }
            }
            Button { m.startTimer() } label: {
                HStack(spacing: 8) { Image(systemName: "play.fill"); Text("Start Timer").font(.system(size: 17, weight: .bold, design: .rounded)) }
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(Theme.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Theme.cyan.opacity(0.3), radius: 12, y: 4)
            }
            Text("Every \(m.interval.rawValue) you'll be reminded to rest your eyes for 20 seconds")
                .font(.system(size: 13, design: .rounded)).foregroundColor(Theme.dim).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).glassCard()
    }

    // MARK: - Working
    private var workingView: some View {
        VStack(spacing: 24) {
            let total = Double(m.interval.seconds)
            let progress = 1.0 - Double(m.remainingSeconds) / total
            ZStack {
                CountdownRing(progress: progress, color: Theme.cyan, lineWidth: 10, size: 220)
                VStack(spacing: 4) {
                    Image(systemName: "eye.fill").font(.system(size: 28)).foregroundStyle(Theme.cyan)
                    Text(formatTime(m.remainingSeconds)).font(.system(size: 48, weight: .bold, design: .rounded)).foregroundColor(Theme.text).monospacedDigit()
                    Text("until break").font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub)
                }
            }
            Button { m.pauseTimer() } label: {
                HStack(spacing: 8) { Image(systemName: "pause.fill"); Text("Pause").font(.system(size: 16, weight: .bold, design: .rounded)) }
                    .foregroundColor(Theme.cyan).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Theme.cyan.opacity(0.1)).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Theme.cyan.opacity(0.25), lineWidth: 1))
            }
        }.frame(maxWidth: .infinity).glassCard()
    }

    // MARK: - Break
    private var breakView: some View {
        VStack(spacing: 20) {
            ZStack {
                CountdownRing(progress: 1.0 - Double(m.breakRemaining) / 20.0, color: Theme.mint, lineWidth: 12, size: 220)
                VStack(spacing: 6) {
                    PulseDot(color: Theme.mint, size: 18)
                    Text("\(m.breakRemaining)").font(.system(size: 56, weight: .bold, design: .rounded)).foregroundColor(Theme.text).monospacedDigit()
                    Text("seconds").font(.system(size: 14, design: .rounded)).foregroundColor(Theme.sub)
                }
            }
            Text("Look at something\n20 feet (6m) away").font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(Theme.mint).multilineTextAlignment(.center)
            Text("Relax your focus. Let your eyes rest on a distant object — a tree, a building, or the horizon.")
                .font(.system(size: 13, design: .rounded)).foregroundColor(Theme.sub).multilineTextAlignment(.center).lineSpacing(3)
        }.frame(maxWidth: .infinity).accentCard(Theme.mint)
    }

    // MARK: - Prompt
    private var promptView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 44)).foregroundStyle(Theme.mint)
            Text("Break Complete!").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
            Text("Want to do a quick eye exercise?").font(.system(size: 14, design: .rounded)).foregroundColor(Theme.sub)
            Button { m.skipExercise() } label: {
                HStack(spacing: 8) { Image(systemName: "arrow.clockwise"); Text("Continue Working").font(.system(size: 15, weight: .bold, design: .rounded)) }
                    .foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 14)
                    .background(Theme.gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            Button { m.skipExercise() } label: {
                Text("Skip").font(.system(size: 14, weight: .medium, design: .rounded)).foregroundColor(Theme.dim)
            }
        }.frame(maxWidth: .infinity).glassCard()
    }

    // MARK: - Today Summary
    private var todaySummary: some View {
        HStack(spacing: 12) {
            statCard("Breaks", "\(m.todayBreaks)", "target: 6+", Theme.cyan)
            statCard("Exercises", "\(m.todayExercises)", "target: 3+", Theme.violet)
            statCard("Score", "\(m.eyeHealthScore)", "out of 100", m.eyeHealthScore >= 70 ? Theme.mint : Theme.amber)
        }
    }

    private func statCard(_ label: String, _ value: String, _ hint: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(color)
            Text(label).font(.system(size: 11, weight: .semibold, design: .rounded)).foregroundColor(Theme.text)
            Text(hint).font(.system(size: 9, design: .rounded)).foregroundColor(Theme.dim)
        }.frame(maxWidth: .infinity).padding(.vertical, 14).glassCard(pad: 0, rad: 16)
    }

    private func formatTime(_ s: Int) -> String {
        String(format: "%d:%02d", s / 60, s % 60)
    }
}
