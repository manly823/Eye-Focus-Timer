import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var manager: EyeManager
    @State private var page = 0
    private let pages: [(icon: String, title: String, desc: String, color: Color)] = [
        ("eye.circle.fill", "Eye Focus Timer", "Protect your vision with the 20-20-20 rule. Every 20 minutes, take a 20-second break and look at something 20 feet away. Your eyes will thank you.", Theme.cyan),
        ("timer.circle.fill", "Smart Timer", "The timer runs in the background while you work. When it's time for a break, you'll get a gentle reminder with haptic feedback and optional sound.", Theme.violet),
        ("figure.mind.and.body", "Eye Exercises", "Six interactive exercises to strengthen eye muscles, improve focus flexibility, and reduce digital eye strain. Follow dots, shift focus, train peripheral vision.", Theme.mint),
        ("chart.bar.fill", "Track Progress", "Monitor your eye health score, daily streaks, breaks taken, and exercises completed. Build healthy habits with visual progress tracking.", Theme.amber)
    ]

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                TabView(selection: $page) { ForEach(0..<pages.count, id: \.self) { i in pageCard(pages[i]).tag(i) } }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { i in
                        Capsule().fill(i == page ? Theme.cyan : Theme.dim)
                            .frame(width: i == page ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: page)
                    }
                }.padding(.bottom, 28)
                Button { if page < pages.count - 1 { withAnimation(.spring(response: 0.4)) { page += 1 } } else { withAnimation { manager.onboardingDone = true } } } label: {
                    HStack(spacing: 8) {
                        Text(page == pages.count - 1 ? "Start Protecting" : "Continue")
                        Image(systemName: page == pages.count - 1 ? "eye.fill" : "arrow.right")
                    }.font(.system(size: 17, weight: .bold, design: .rounded)).foregroundStyle(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                        .background(Theme.gradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Theme.cyan.opacity(0.3), radius: 12, y: 4)
                }.padding(.horizontal, 30).padding(.bottom, 20)
                if page < pages.count - 1 { Button("Skip") { withAnimation { manager.onboardingDone = true } }.font(.system(size: 15, weight: .medium, design: .rounded)).foregroundColor(Theme.sub).padding(.bottom, 20) }
                else { Color.clear.frame(height: 40) }
            }
        }
    }

    private func pageCard(_ p: (icon: String, title: String, desc: String, color: Color)) -> some View {
        VStack(spacing: 24) {
            Spacer()
            ZStack {
                Circle().fill(p.color.opacity(0.08)).frame(width: 170, height: 170).blur(radius: 35)
                Circle().fill(Theme.surface).frame(width: 130, height: 130).overlay(Circle().stroke(p.color.opacity(0.25), lineWidth: 2))
                Image(systemName: p.icon).font(.system(size: 52, weight: .medium)).foregroundStyle(LinearGradient(colors: [p.color, p.color.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
            }.shadow(color: p.color.opacity(0.3), radius: 20)
            VStack(spacing: 12) {
                Text(p.title).font(.system(size: 26, weight: .bold, design: .rounded)).foregroundColor(Theme.text)
                Text(p.desc).font(.system(size: 16, design: .rounded)).foregroundColor(Theme.sub).multilineTextAlignment(.center).lineSpacing(4).padding(.horizontal, 28)
            }; Spacer(); Spacer()
        }
    }
}
