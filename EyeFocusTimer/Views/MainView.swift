import SwiftUI

enum EyeTab: String, CaseIterable, Identifiable {
    case timer = "Timer"
    case exercises = "Exercises"
    case stats = "Stats"
    case settings = "Settings"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .timer: return "timer"
        case .exercises: return "figure.mind.and.body"
        case .stats: return "chart.bar.fill"
        case .settings: return "gearshape.fill"
        }
    }
    var color: Color {
        switch self {
        case .timer: return Theme.cyan
        case .exercises: return Theme.violet
        case .stats: return Theme.mint
        case .settings: return Theme.sub
        }
    }
}

struct MainView: View {
    @EnvironmentObject var manager: EyeManager
    @State private var tab: EyeTab = .timer

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                content.frame(maxWidth: .infinity, maxHeight: .infinity)
                dockBar
            }
        }
    }

    @ViewBuilder private var content: some View {
        switch tab {
        case .timer: TimerView()
        case .exercises: ExercisesView()
        case .stats: StatsView()
        case .settings: SettingsView()
        }
    }

    private var dockBar: some View {
        HStack(spacing: 0) {
            ForEach(EyeTab.allCases) { t in
                Button { withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) { tab = t } } label: {
                    VStack(spacing: 4) {
                        ZStack {
                            if tab == t {
                                Circle().fill(t.color.opacity(0.15)).frame(width: 48, height: 48)
                                    .overlay(Circle().stroke(t.color.opacity(0.3), lineWidth: 1.5))
                            }
                            Image(systemName: t.icon).font(.system(size: 18, weight: tab == t ? .semibold : .regular))
                                .foregroundColor(tab == t ? t.color : Theme.dim)
                                .scaleEffect(tab == t ? 1.1 : 1.0)
                        }.frame(height: 48)
                        if tab == t {
                            Text(t.rawValue).font(.system(size: 9, weight: .bold, design: .rounded)).foregroundColor(t.color)
                                .transition(.opacity.combined(with: .scale(scale: 0.5)))
                        }
                    }.frame(maxWidth: .infinity)
                }.buttonStyle(.plain)
            }
        }
        .padding(.vertical, 6).padding(.bottom, 4)
        .background(.ultraThinMaterial.opacity(0.3))
        .background(Theme.surface.opacity(0.8))
    }
}
